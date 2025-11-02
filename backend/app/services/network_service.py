# app/services/network_service.py
import subprocess

def autorizar_usuario(ip: str):
    """
    Inserta una regla iptables para aceptar tráfico desde la IP del cliente.
    Requiere que el servidor tenga NAT/reenvío habilitado y privilegios sudo.
    """
    # evita duplicados: intenta insertar en posición 1
    cmd = ["sudo", "iptables", "-C", "FORWARD", "-s", ip, "-j", "ACCEPT"]
    try:
        subprocess.run(cmd, check=True, capture_output=True, text=True)
        # si el -C no falla, la regla ya existe -> nada que hacer
        return {"ok": True, "msg": "ya_autorizado"}
    except subprocess.CalledProcessError:
        # regla no existe -> añadirla
        cmd2 = ["sudo", "iptables", "-I", "FORWARD", "-s", ip, "-j", "ACCEPT"]
        subprocess.run(cmd2, check=True)
        return {"ok": True, "msg": "autorizado"}

def revocar_usuario(ip: str):
    """
    Elimina la regla que permite tráfico desde la IP del cliente.
    """
    cmd = ["sudo", "iptables", "-D", "FORWARD", "-s", ip, "-j", "ACCEPT"]
    try:
        subprocess.run(cmd, check=True)
        return {"ok": True}
    except subprocess.CalledProcessError as e:
        return {"ok": False, "error": str(e)}
