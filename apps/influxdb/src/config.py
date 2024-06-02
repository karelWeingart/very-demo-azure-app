from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    KEYVAULT_ENDPOINT: str

# global instance
settings = Settings()