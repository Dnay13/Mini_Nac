from pydantic import BaseModel
from typing import Optional
from datetime import datetime, timedelta

class InvitadoBase(BaseModel):
    username: str
    expiracion: Optional[datetime] = None
    session_timeout: Optional[int] = 0  # en minutos
    estado: Optional[str] = "activo"

class InvitadoCreate(InvitadoBase):
    password: str
    creado_por: int  # ID del admin que crea el invitado

class InvitadoOut(InvitadoBase):
    id: int
    uid: str
    creado_en: datetime
    actualizado_en: datetime
    class Config:
        from_attributes = True