from fastapi import FastAPI
from app.api import admin_router, invitados_router
from app.db import base_class, session

app = FastAPI(title="Mini NAC Backend")

# Routers
app.include_router(admin_router.router)
app.include_router(invitados_router.router)

@app.get("/")
def root():
    return {"message": "Mini NAC API funcionando ✅"}
