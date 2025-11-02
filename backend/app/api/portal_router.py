# app/api/portal_router.py
from fastapi import APIRouter, Request, Form, Depends, BackgroundTasks, HTTPException
from fastapi.responses import HTMLResponse, RedirectResponse
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
import time

from app.db.session import SessionLocal
from app.models.invitado import UsuarioInvitado
from app.services.network_service import autorizar_usuario, revocar_usuario

router = APIRouter(prefix="/portal", tags=["Portal"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Simple login page (browser)
@router.get("/login", response_class=HTMLResponse)
def login_page():
    html = """
    <html>
      <head><title>Login - MiniNac</title></head>
      <body>
        <h2>Ingresar credenciales</h2>
        <form method="post" action="/portal/login">
          Usuario: <input name="username" type="text"/><br/>
          Contraseña: <input name="password" type="password"/><br/>
          <input type="submit" value="Entrar"/>
        </form>
      </body>
    </html>
    """
    return HTMLResponse(content=html)

def sesion_temporal_task(ip: str, duracion_seg: int):
    autorizar_usuario(ip)
    time.sleep(duracion_seg)
    revocar_usuario(ip)

@router.post("/login")
def portal_login(
    request: Request,
    username: str = Form(...),
    password: str = Form(...),
    background_tasks: BackgroundTasks = None,
    db: Session = Depends(get_db)
):
    """
    Procesa el login del portal. Valida contra la tabla usuarios_invitados
    (o puedes validar con radcheck/radius si prefieres).
    Autoriza la IP cliente durante session_timeout segundos.
    """
    invitado = db.query(UsuarioInvitado).filter_by(username=username).first()
    if not invitado:
        return HTMLResponse("<h3>Usuario no encontrado</h3>", status_code=401)

    # *IMPORTANTE*: Aquí asumimos contraseña en claro en DB (solo prueba).
    # En producción usar hashing (bcrypt) y comparar.
    if password != invitado.password:
        return HTMLResponse("<h3>Contraseña inválida</h3>", status_code=401)

    # calcular duración en segundos (si session_timeout=0 usa expiracion diff)
    if invitado.session_timeout and invitado.session_timeout > 0:
        duracion = invitado.session_timeout * 60
    else:
        # si expiracion existe, usa diferencia; si no, default 1 hora
        if invitado.expiracion:
            diff = (invitado.expiracion - datetime.utcnow()).total_seconds()
            duracion = max(0, int(diff))
        else:
            duracion = 3600

    # obtener ip del cliente (nota: si hay proxy / NAT, request.client.host cambia)
    ip_cliente = request.client.host

    # autorizar y programar revocación en background
    autorizar_usuario(ip_cliente)
    if background_tasks:
        background_tasks.add_task(sesion_temporal_task, ip_cliente, duracion)

    # registra evento opcional en BD o radacct (si quieres)
    # redirige a página de éxito o al recurso solicitado
    html = f"<html><body><h3>Acceso concedido por {duracion} segundos</h3></body></html>"
    return HTMLResponse(html)
