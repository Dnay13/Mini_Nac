from fastapi import FastAPI
from app.api import admin_router, invitados_router
from app.db import base_class, session
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Mini NAC Backend")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Puedes restringirlo luego a tu dominio Flutter o ngrok
    allow_credentials=True,
    allow_methods=["*"],  # Permitir todos los métodos: GET, POST, OPTIONS, etc.
    allow_headers=["*"],  # Permitir todos los encabezados
)
# Routers
app.include_router(admin_router.router)
app.include_router(invitados_router.router)

@app.get("/")
def root():
    return {"message": "Mini NAC API funcionando ✅"}
