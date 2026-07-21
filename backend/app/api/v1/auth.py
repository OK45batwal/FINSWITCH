from fastapi import APIRouter, Depends, HTTPException, status
from app.core.security import hash_password, verify_password, create_access_token, create_refresh_token, get_current_user
from app.schemas.user import UserCreate, UserLogin, TokenResponse, UserResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])

users_db = {}


@router.post("/register", response_model=TokenResponse)
async def register(data: UserCreate):
    if data.email in users_db:
        raise HTTPException(status_code=400, detail="Email already registered")
    user = {
        "id": str(hash(data.email))[:12],
        "email": data.email,
        "password_hash": hash_password(data.password),
        "display_name": data.display_name or data.email.split("@")[0],
        "role": "user",
        "is_verified": False,
    }
    users_db[data.email] = user
    return TokenResponse(
        access_token=create_access_token({"sub": user["id"], "email": data.email}),
        refresh_token=create_refresh_token({"sub": user["id"]}),
    )


@router.post("/login", response_model=TokenResponse)
async def login(data: UserLogin):
    user = users_db.get(data.email)
    if not user or not verify_password(data.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return TokenResponse(
        access_token=create_access_token({"sub": user["id"], "email": data.email}),
        refresh_token=create_refresh_token({"sub": user["id"]}),
    )


@router.get("/me", response_model=UserResponse)
async def get_me(user_id: str = Depends(get_current_user)):
    for u in users_db.values():
        if u["id"] == user_id:
            return UserResponse(
                id=u["id"], email=u["email"],
                display_name=u["display_name"], avatar_url=None,
                role=u["role"], is_verified=u["is_verified"],
                created_at=datetime.now(),
            )
    raise HTTPException(status_code=404, detail="User not found")


from datetime import datetime
