#Archivo encargado de centralizar conexiones y definer sesiones
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
#Importar la configuracion de .env desde el settings de config en el core
from app.core.config import settings

# Motor para base de datos principal
engine_main = create_engine(settings.MYSQL_MAIN_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine_main)

# Motor para base de datos RADIUS
engine_radius = create_engine(settings.MYSQL_RADIUS_URL)
SessionRadius = sessionmaker(autocommit=False, autoflush=False, bind=engine_radius)