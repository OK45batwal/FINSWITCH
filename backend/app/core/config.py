from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    APP_NAME: str = "FinSwitch"
    DEBUG: bool = True
    SECRET_KEY: str = "dev-secret-key-change-in-prod"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    CORS_ORIGINS: list[str] = ["*"]

    class Config:
        env_file = ".env"

settings = Settings()
