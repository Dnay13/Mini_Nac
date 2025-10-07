#revisar
from sqlalchemy import text
from app.db.session import engine_radius

def crear_usuario_radius(username: str, password: str, timeout: int = 0):
    with engine_radius.begin() as conn:
        conn.execute(text("""
            INSERT INTO radcheck (username, attribute, op, value)
            VALUES (:u, 'Cleartext-Password', ':=', :p)
        """), {"u": username, "p": password})

        if timeout > 0:
            conn.execute(text("""
                INSERT INTO radreply (username, attribute, op, value)
                VALUES (:u, 'Session-Timeout', ':=', :t)
            """), {"u": username, "t": str(timeout)})
