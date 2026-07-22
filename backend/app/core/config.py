from typing import Union
from pydantic import field_validator
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    APP_NAME: str = "FinSwitch"
    DEBUG: bool = True
    SECRET_KEY: str = "dev-secret-key-change-in-prod"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    CORS_ORIGINS: Union[list[str], str] = ["*"]

    @field_validator("CORS_ORIGINS", mode="before")
    @classmethod
    def assemble_cors_origins(cls, v: Union[str, list[str]]) -> list[str]:
        if isinstance(v, str) and not v.startswith("["):
            return [i.strip() for i in v.split(",") if i.strip()]
        if isinstance(v, list):
            return v
        return ["*"]

    def model_post_init(self, __context):
        if not self.DEBUG:
            if not self.SECRET_KEY or self.SECRET_KEY == "dev-secret-key-change-in-prod" or len(self.SECRET_KEY) < 16:
                raise ValueError("CRITICAL: SECRET_KEY must be set to a strong custom secret string in production (DEBUG=False).")
            if self.CORS_ORIGINS == ["*"]:
                self.CORS_ORIGINS = ["https://finswitch.pages.dev"]

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()
