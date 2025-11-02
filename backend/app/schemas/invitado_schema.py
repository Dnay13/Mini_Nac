from pydantic import BaseModel
from typing import Optional
from datetime import datetime

# -------------------------------------------------------------
# 🧩 Esquema base: atributos comunes a todas las versiones
# -------------------------------------------------------------
class InvitadoBase(BaseModel):
    username: str
    expiracion: Optional[datetime] = None
    session_timeout: Optional[int] = 0  # en minutos
    estado: Optional[str] = "activo"

# -------------------------------------------------------------
# 🆕 Esquema para crear un invitado (lo que el cliente envía)
# -------------------------------------------------------------
class InvitadoCreate(InvitadoBase):
    password: str
    creado_por: int  # ID del admin que crea el invitado
    max_down: Optional[int] = None  # en Kbps
    max_up: Optional[int] = None  # en Kbps

# -------------------------------------------------------------
# 📤 Esquema de salida (lo que la API devuelve)
# -------------------------------------------------------------
class InvitadoOut(InvitadoBase):
    id: int
    uid: str
    creado_en: datetime
    actualizado_en: datetime

    class Config:
        orm_mode = True  # 👈 necesario para convertir desde objetos SQLAlchemy
