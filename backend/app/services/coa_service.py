#revisar
import subprocess

def enviar_coa(username: str, ap_ip: str, secret: str):
    cmd = f"(echo 'User-Name = {username}') | radclient -x {ap_ip}:3799 coa {secret}"
    subprocess.run(cmd, shell=True, check=True)
