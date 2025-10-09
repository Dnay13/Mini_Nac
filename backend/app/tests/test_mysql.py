import pymysql

connection = pymysql.connect(
    host='0.tcp.sa.ngrok.io',
    port=18588,
    user='miniadmin',
    password='admin',
    database='mini_nac'
)

print("✅ Conexión establecida con MySQL a través de ngrok")

with connection.cursor() as cursor:
    cursor.execute("SELECT DATABASE();")
    result = cursor.fetchone()
    print("Base de datos actual:", result)

connection.close()
