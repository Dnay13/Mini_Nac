from fastapi import APIRouter, Depends, HTTPException, BackgroundTasks, Request
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import time

from app.db.session import SessionLocal
from app.models.invitado import UsuarioInvitado
from app.schemas.invitado_schema import InvitadoCreate, InvitadoOut
from app.services.radius_service import crear_usuario_radius
from app.services.coa_service import enviar_coa
from app.services.network_service import autorizar_usuario, revocar_usuario


router = APIRouter(prefix="/users", tags=["Invitados"])

# -------------------------------------------------------------
# 📦 Dependencia para obtener la sesión de base de datos
# -------------------------------------------------------------
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# -------------------------------------------------------------
# 🧩 Sesión temporal (autoriza y revoca IP automáticamente)
# -------------------------------------------------------------
def sesion_temporal(ip: str, duracion_seg: int):
    autorizar_usuario(ip)
    time.sleep(duracion_seg)
    revocar_usuario(ip)

# -------------------------------------------------------------
# 🧩 1. Crear invitado nuevo
# -------------------------------------------------------------
@router.post("/", response_model=InvitadoOut)
def crear_invitado(
    data: InvitadoCreate,
    request: Request,  # para obtener la IP del cliente
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    # Generar UID autoincremental tipo USR1, USR2, etc.
    ultimo = db.query(UsuarioInvitado).order_by(UsuarioInvitado.id.desc()).first()
    nuevo_numero = 1
    if ultimo and ultimo.uid and ultimo.uid.startswith("USR"):
        try:
            nuevo_numero = int(ultimo.uid.replace("USR", "")) + 1
        except ValueError:
            nuevo_numero = 1
    nuevo_uid = f"USR{nuevo_numero}"

    nuevo = UsuarioInvitado(
        uid=nuevo_uid,
        username=data.username,
        password=data.password,
        expiracion=data.expiracion,
        session_timeout=data.session_timeout,
        creado_por=data.creado_por,
        estado="activo"
    )

    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)

    # Crear también en FreeRADIUS
    try:
        crear_usuario_radius(
            username=data.username,
            password=data.password,
            session_timeout=data.session_timeout,
            max_down=getattr(data, "max_down", None),
            max_up=getattr(data, "max_up", None)
        )

        # 🔹 Autorizar IP temporalmente
        ip_cliente = request.client.host
        duracion_seg = data.session_timeout * 60 if data.session_timeout else 600  # 10 min por defecto
        background_tasks.add_task(sesion_temporal, ip_cliente, duracion_seg)

    except Exception as e:
        db.delete(nuevo)
        db.commit()
        raise HTTPException(status_code=500, detail=f"Error al crear en RADIUS: {e}")

    return nuevo

# -------------------------------------------------------------
# 📜 2. Listar todos los invitados
# -------------------------------------------------------------
@router.get("/", response_model=list[InvitadoOut])
def listar_invitados(db: Session = Depends(get_db)):
    return db.query(UsuarioInvitado).all()

# -------------------------------------------------------------
# 🔍 3. Obtener un invitado específico por UID
# -------------------------------------------------------------
@router.get("/{uid}", response_model=InvitadoOut)
def obtener_invitado(uid: str, db: Session = Depends(get_db)):
    invitado = db.query(UsuarioInvitado).filter_by(uid=uid).first()
    if not invitado:
        raise HTTPException(status_code=404, detail="Invitado no encontrado")
    return invitado

# -------------------------------------------------------------
# ❌ 4. Eliminar un invitado
# -------------------------------------------------------------
@router.delete("/{uid}")
def eliminar_invitado(uid: str, db: Session = Depends(get_db)):
    invitado = db.query(UsuarioInvitado).filter_by(uid=uid).first()
    if not invitado:
        raise HTTPException(status_code=404, detail="Invitado no encontrado")

    db.delete(invitado)
    db.commit()
    return {"message": f"Invitado {uid} eliminado correctamente"}

# -------------------------------------------------------------
# ⏳ 5. Verificar estado de sesión
# -------------------------------------------------------------
@router.get("/{uid}/estado")
def verificar_estado(uid: str, db: Session = Depends(get_db)):
    invitado = db.query(UsuarioInvitado).filter_by(uid=uid).first()
    if not invitado:
        raise HTTPException(status_code=404, detail="Invitado no encontrado")

    expiracion = invitado.expiracion or (
        invitado.creado_en + timedelta(minutes=invitado.session_timeout)
    )
    tiempo_restante = expiracion - datetime.now()
    activo = tiempo_restante.total_seconds() > 0 and invitado.estado == "activo"

    return {
        "uid": uid,
        "activo": activo,
        "tiempo_restante_min": max(tiempo_restante.total_seconds() / 60, 0)
    }

# -------------------------------------------------------------
# ⚙️ 6. Desconectar manualmente un usuario (CoA)
# -------------------------------------------------------------
@router.post("/{username}/desconectar")
def desconectar_usuario(username: str):
    try:
        enviar_coa(username, ap_ip="192.168.18.1", secret="clave_radius")
        # También puedes revocar su IP (si la tienes guardada)
        # revocar_usuario(ip_cliente)
        return {"message": f"Usuario {username} desconectado correctamente"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error al desconectar: {e}")
