import subprocess

def enviar_coa(username: str, ap_ip: str, secret: str):
    try:
        cmd = f"(echo 'User-Name = {username}') | radclient -x {ap_ip}:3799 coa {secret}"
        result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        return result.stdout
    except subprocess.CalledProcessError as e:
        return f"Error al enviar CoA: {e.stderr}"
