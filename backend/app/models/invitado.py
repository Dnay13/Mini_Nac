#Archivo de modelo de la tabla de los usuarios invitados
#Tipos de columnas y datos a usar
from sqlalchemy import Column, Integer, String, DateTime, Enum, ForeignKey, TIMESTAMP
from sqlalchemy.sql import func
#Importacion de la base declarativa
from app.db.base_class import Base

class UsuarioInvitado(Base):
    __tablename__="usuarios_invitados"
    id=Column(Integer, primary_key=True, index=True)
    uid = Column(String(20), unique=True, nullable=False)
    username = Column(String(100), unique=True, nullable=False)
    password = Column(String(100), nullable=False)
    expiracion = Column(DateTime)
    session_timeout= Column(Integer, default=0)
    max_daily_session= Column(Integer, default=0)
    estado= Column(Enum("activo","expirado","revocado"), default="activo")
    creado_por=Column(Integer, ForeignKey("administradores.id", ondelete="CASCADE" ))
    creado_en=Column(TIMESTAMP, server_default=func.now(), nullable=False)
    actualizado_en=Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())
