from sqlalchemy import text
from app.db.session import engine_radius

def crear_usuario_radius(username: str, password: str, session_timeout: int = 0, max_down: int | None = None, max_up: int | None = None):
    """
    Crea un usuario en FreeRADIUS (tablas radcheck y radreply).
    - username: nombre de usuario del invitado
    - password: contraseña en texto claro
    - session_timeout: duración máxima de sesión en minutos
    - max_down / max_up: límite de velocidad en Kbps
    """
    try:
        with engine_radius.begin() as conn:  # begin() -> maneja commit automático
            # ✅ Insertar credenciales en radcheck
            conn.execute(text("""
                INSERT INTO radcheck (username, attribute, op, value)
                VALUES (:username, 'Cleartext-Password', ':=', :password)
            """), {"username": username, "password": password})

            # ✅ Tiempo máximo de sesión
            if session_timeout > 0:
                conn.execute(text("""
                    INSERT INTO radreply (username, attribute, op, value)
                    VALUES (:username, 'Session-Timeout', ':=', :timeout)
                """), {"username": username, "timeout": str(session_timeout * 60)})

            # ✅ Límite de velocidad (bajada)
            if max_down:
                conn.execute(text("""
                    INSERT INTO radreply (username, attribute, op, value)
                    VALUES (:username, 'WISPr-Bandwidth-Max-Down', ':=', :max_down)
                """), {"username": username, "max_down": str(max_down)})

            # ✅ Límite de velocidad (subida)
            if max_up:
                conn.execute(text("""
                    INSERT INTO radreply (username, attribute, op, value)
                    VALUES (:username, 'WISPr-Bandwidth-Max-Up', ':=', :max_up)
                """), {"username": username, "max_up": str(max_up)})

    except Exception as e:
        raise Exception(f"❌ Error creando usuario en RADIUS: {e}")
