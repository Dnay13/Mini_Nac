#Archivo de modelo de la tabla de los QRs
#Tipos de columnas y datos a usar
from sqlalchemy import Column, Integer, String, DateTime, Enum, ForeignKey, TIMESTAMP
from sqlalchemy.sql import func
#Importacion de la base declarativa
from app.db.base_class import Base

class QrCodes(Base):
    __tablename__="qr_codes"
    id=Column(Integer, primary_key=True, index=True)
    uid = Column(String(20), unique=True, nullable=False)
    invitado_id=Column(Iteger, ForeignKey("usuarios_invitados.id", ondelete="CASCADE"))
    ssid=Column(String(100), nullable=False)
    tipo_auth=Column(String(50), default="WPA2-EAP")
    qr_string=Column(Text, nullable=False)
    estado= Column(Enum("activo","expirado"), default="activo")
    creado_en=Column(TIMESTAMP, server_default=func.now())
    actualizado_en=Column(TIMESTAMP, server_default=func.now(), onupdate=func.now())
    