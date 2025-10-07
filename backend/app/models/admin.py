#Archivo de modelo de la tabla de administradores
#Tipos de columnas y datos a usar
from sqlalchemy import Column, Integer, String, DateTime, Enum, Boolean, TIMESTAMP
from sqlalchemy.sql import func
#Importacion de la base declarativa
from app.db.base_class import Base

class Administrador(Base):
    __tablename__ = "administradores"
    id = Column(Integer, primary_key=True, index=True)
    uid = Column(String(20), unique=True, nullable=False)
    nombre = Column(String(100), nullable=False)
    correo = Column(String(150), unique=True, index=True, nullable=False)
    foto_url = Column(String(255))
    rol = Column(Enum('superadmin', 'admin'), default='admin')
    activo = Column(Boolean, default=True)
    creado_en = Column(TIMESTAMP, server_default=func.now())
    actualizado_en = Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())
    password = Column(String(255), nullable=False)