#revisar
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.invitado import UsuarioInvitado
from app.schemas.invitado_schema import InvitadoCreate, InvitadoOut
from app.services.radius_service import crear_usuario_radius

router = APIRouter(prefix="/users", tags=["Invitados"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=InvitadoOut)
def crear_invitado(data: InvitadoCreate, db: Session = Depends(get_db)):
    nuevo = UsuarioInvitado(
        uid=f"USR{db.query(UsuarioInvitado).count()+1:04d}",
        username=data.username,
        password=data.password,
        creado_por=data.creado_por,
        session_timeout=data.session_timeout
    )
    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    
    # Crear también en RADIUS
    crear_usuario_radius(data.username, data.password, data.session_timeout)
    
    return nuevo
