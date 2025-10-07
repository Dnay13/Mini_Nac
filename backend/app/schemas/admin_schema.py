#Define esquemas validados automaticos
from pydantic import BaseModel
from typing import Optional
from datetime import datetime

# Esquema base para un administrador
class AdminBase(BaseModel):
    nombre: str
    correo: str
    rol: Optional[str] = "admin"
    foto_url: Optional[str] = None
# Esquema para crear un nuevo administrador, incluye la contraseña
class AdminCreate(AdminBase):
    password: str
# Esquema para regresar datos de un administrador. Usa ORM para facilitar las consultas
class AdminOut(AdminBase):
    id: int
    uid: str
    creado_en: datetime
    actualizado_en: datetime
    activo: Optional[bool] = True
    class Config:
        from_attributes = True

