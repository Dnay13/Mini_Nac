#Archivo de modelo de la tabla de logs
#Tipos de columnas y datos a usar
from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey, TIMESTAMP
from sqlalchemy.sql import func
#Importacion de la base declarativa
from app.db.base_class import Base

class Logs(Base):
    __tablename__="admin_logs"
    id=Column(Integer, primary_key=True)
    admin_id=Column(Integer, ForeignKey("administradores.id", ondelete="CASCADE"))
    accion=Column(String(200), nullable=False)
    detalle=Column(Text)
    fech=Column(TIMESTAMP, server_default=func.now())

