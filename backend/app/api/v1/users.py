from fastapi import APIRouter, Depends, HTTPException
from app.core.security import get_current_user

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me")
async def get_current_user_profile(user_id: str = Depends(get_current_user)):
    return {
        "success": True,
        "data": {
            "id": user_id,
            "email": "user@example.com",
            "display_name": "Demo User",
            "phone": "+91-9876543210",
            "role": "user",
            "plan": "free",
            "is_verified": True,
            "preferences": {"theme": "dark", "language": "en", "currency": "INR", "notifications": True},
            "created_at": "2026-01-15T10:30:00Z",
        },
    }


@router.put("/me")
async def update_profile(data: dict, user_id: str = Depends(get_current_user)):
    return {"success": True, "message": "Profile updated"}


@router.put("/me/preferences")
async def update_preferences(data: dict, user_id: str = Depends(get_current_user)):
    return {"success": True, "message": "Preferences updated"}
