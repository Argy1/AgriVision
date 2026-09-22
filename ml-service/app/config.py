from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    supabase_url: str
    supabase_service_role_key: str
    storage_bucket: str = "plant-photos"
    model_dir: str = "models"
    allowed_origins: str = "*"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        protected_namespaces=(),
        extra="ignore",  # .env boleh punya var lain yang cuma dipakai test (SUPABASE_ANON_KEY)
    )


settings = Settings()
