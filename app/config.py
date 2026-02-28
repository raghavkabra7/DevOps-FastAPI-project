"""Configuration management for the application."""
import os
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Application settings."""
    
    app_name: str = "Item Management API"
    app_version: str = "1.0.0"
    environment: str = "development"
    debug: bool = True
    
    database_url: str = "postgresql://postgres:postgres@localhost:5432/itemsdb"
    
    host: str = "0.0.0.0"
    port: int = 8000
    
    log_level: str = "INFO"
    
    class Config:
        """Pydantic configuration."""
        env_file = ".env"
        case_sensitive = False


settings = Settings()
