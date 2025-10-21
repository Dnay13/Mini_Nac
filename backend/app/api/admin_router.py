from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.admin import Administrador
from app.schemas.admin_schema import AdminCreate, AdminOut

router = APIRouter(prefix="/admin", tags=["Admin"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


@router.post("/users", response_model=AdminOut)
def crear_admin(admin: AdminCreate, db: Session = Depends(get_db)):
    # 1️⃣ Buscar el último UID insertado
    ultimo = db.query(Administrador).order_by(Administrador.uid.desc()).first()

    if ultimo:
        # 2️⃣ Extraer número de UID actual: ADM10 → 10
        numero_actual = int(ultimo.uid.replace("ADM", ""))
        nuevo_numero = numero_actual + 1
    else:
        nuevo_numero = 1  # Si no hay registros, empezamos desde 1

    # 3️⃣ Generar UID nuevo
    nuevo_uid = f"ADM{nuevo_numero}"

    # 4️⃣ Crear nuevo admin
    nuevo = Administrador(
        uid=nuevo_uid,
        nombre=admin.nombre,
        correo=admin.correo,
        rol=admin.rol,
        foto_url=admin.foto_url,
        password=admin.password
    )


    db.add(nuevo)
    db.commit()
    db.refresh(nuevo)
    return nuevo

@router.get("/users", response_model=list[AdminOut])
def listar_admins(db: Session = Depends(get_db)):
    admins = db.query(Administrador).all()
    return admins
@router.get("/logs")
def listar_logs():
    return {"message": "Aquí irán los logs"}
