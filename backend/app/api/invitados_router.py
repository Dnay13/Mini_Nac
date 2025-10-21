from fastapi import APIRouter, Depends, HTTPException
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
    # Generar UID autoincremental
    ultimo = db.query(UsuarioInvitado).order_by(UsuarioInvitado.uid.desc()).first()
    nuevo_numero = int(ultimo.uid.replace("USR", "")) + 1 if ultimo else 1
    nuevo_uid = f"USR{nuevo_numero}"

    nuevo = UsuarioInvitado(
        uid=nuevo_uid,
        username=data.username,
        password=data.password,
        creado_por=data.creado_por,
        session_timeout=data.session_timeout
    )

    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)

    # Crear usuario en FreeRADIUS
    try:
        crear_usuario_radius(data.username, data.password, data.session_timeout)
    except Exception as e:
        db.delete(nuevo)
        db.commit()
        raise HTTPException(status_code=500, detail=f"Error al crear en RADIUS: {e}")

    return nuevo
