#Archivo donde se configuran las variables de entorno, extraidas desde el .env
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    MYSQL_MAIN_URL: str
    MYSQL_RADIUS_URL: str
    FIREBASE_CREDENTIALS: str
    
    
    class Config:
        env_file = ".env"
settings = Settings()