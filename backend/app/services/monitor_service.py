# app/services/monitor_service.py
from sqlalchemy import text
from app.db.session import engine_radius


def obtener_sesiones_activas():
    with engine_radius.connect() as conn:
        resultado = conn.execute(text("""
            SELECT username, acctstarttime, acctstoptime,
                   acctinputoctets, acctoutputoctets
            FROM radacct
            WHERE acctstoptime IS NULL
        """))
        return [dict(row._mapping) for row in resultado]
