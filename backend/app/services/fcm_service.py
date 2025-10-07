#revisar
import firebase_admin
from firebase_admin import credentials, messaging
from app.core.config import settings

cred = credentials.Certificate(settings.FIREBASE_CREDENTIALS)
firebase_admin.initialize_app(cred)

def enviar_notificacion(titulo, cuerpo, topic="admins"):
    msg = messaging.Message(
        notification=messaging.Notification(title=titulo, body=cuerpo),
        topic=topic
    )
    messaging.send(msg)
