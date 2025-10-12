from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import admin_router, invitados_router
from app.db import base_class, session  # se asegura de crear las tablas al iniciar

app = FastAPI(title="Mini NAC Backend")

# CORS (puedes cambiar "*" por tu dominio Flutter o Render)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  
    allow_credentials=True,
    allow_methods=["*"],  
    allow_headers=["*"],  
)

# Routers
app.include_router(admin_router.router)
app.include_router(invitados_router.router)

# Ruta raíz para comprobar que el backend funciona
@app.get("/")
def root():
    return {"message": "Mini NAC API funcionando correctamente ✅"}

# Esto es opcional, pero útil si quieres que Render cree tus tablas al iniciar
@app.on_event("startup")
def startup_event():
    from app.db.session import engine
    from app.db import base_class
    base_class.Base.metadata.create_all(bind=engine)
