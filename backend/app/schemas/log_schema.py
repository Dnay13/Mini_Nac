from pydantic import BaseModel
from typing import Optional
from datetime import datetime

# Modelo base (campos comunes)
class LogBase(BaseModel):
    accion: str
    detalle: str
    admin_id: Optional[int] = None  # quién realizó la acción

# Modelo de salida (lo que devuelve la API)
class LogOut(LogBase):
    id: int
    fecha: datetime

    class Config:
        from_attributes = True
