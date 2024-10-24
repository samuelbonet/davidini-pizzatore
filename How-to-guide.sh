1. Crear BBDD MariaDB según parámetros permitidos en el Sandox y habilitar el acceso público
	1.1. Creamos la BBDD con contraseña maestra por limitaciones de Sandbox
2. En DBeaver crear una conexión a la base de datos
3. Crear base de datos y tablas:

CREATE DATABASE IF NOT EXISTS pizzeria

CREATE TABLE IF NOT EXISTS Usuarios(usuario VARCHAR(255) NOT NULL, contraseña VARCHAR(255) NOT NULL, PRIMARY KEY(usuario))

INSERT INTO Usuarios(usuario,contraseña) VALUES('usuario1','123admin')

SELECT * FROM Usuarios

4. Creamos un directorio con las dependencias. Instalamos mysql connector
	4.1. pip install mysql-connector-python==8.0.26 -t .
5. Creamos el archivo lambda_function.py. Hacemos una query de test:

```
import json
import mysql.connector

def lambda_handler(event, context):
    # TODO implement
    mydb = mysql.connector.connect(
      host="pizzeria-mourinho.cxjnadenupc0.us-east-1.rds.amazonaws.com",
      user="admin",
      password="adminadmin",
      database="pizzeria"
    )
    mycursor = mydb.cursor()
    mycursor.execute("SELECT * FROM Users")
    myresult = mycursor.fetchall()
    return {
        'statusCode': 200,
        'body': json.dumps(myresult)
    }
```

6. Query para insertar. Hace falta commitear los registros que se quieren añadir

```
import json
import mysql.connector

def lambda_handler(event, context):
    # Extraer los datos del evento
    user = event['user']
    passwd = event['password']
    
    # Conectar a la base de datos
    mydb = mysql.connector.connect(
      host="pizzeria-mourinho.cxjnadenupc0.us-east-1.rds.amazonaws.com",
      user="admin",
      password="adminadmin",
      database="pizzeria"
    )
    
    mycursor = mydb.cursor()
    
    try:
        # Consulta de inserción (Insertar el nuevo registro)
        insert_query = "INSERT INTO Users(usuario, contraseña) VALUES (%s, %s)"
        mycursor.execute(insert_query, (user, passwd))
        
        # Hacer commit para confirmar la inserción
        mydb.commit()
        
        # Recuperar el registro insertado (asumiendo que 'usuario' es único)
        select_query = "SELECT usuario, contraseña FROM Users WHERE usuario = %s"
        mycursor.execute(select_query, (user,))
        myresult = mycursor.fetchone()  # Obtener un único resultado
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Usuario insertado correctamente',
                'user': myresult
            })
        }
    
    except mysql.connector.Error as err:
        # En caso de error, retornar el mensaje del error
        return {
            'statusCode': 500,
            'body': json.dumps({
                'message': 'Error al insertar el usuario',
                'error': str(err)
            })
        }
    
    finally:
        # Cerrar el cursor y la conexión a la base de datos
        mycursor.close()
        mydb.close()
```

7. Creamos un evento de test. Simula el JSON que nos envía la API
{
	"user": "user1",
	"password": "asodfjna"
}

8. Modificamos el código para tener ambas funciones simultáneamente

```
import json
import mysql.connector

def lambda_handler(event, context):
    # TODO implement
    mydb = mysql.connector.connect(
      host="pizzeria-mourinho.cxjnadenupc0.us-east-1.rds.amazonaws.com",
      user="admin",
      password="adminadmin",
      database="pizzeria"
    )

    if(event['operation'] == 'select'):
        cursor = mydb.cursor()
        response = select_users(cursor)
        return response
    elif(event['operation'] == 'insert'):
        cursor = mydb.cursor()
        response = insert_user(mydb, cursor, event['user'], event['password'])
        return response

def select_users(cursor):
    cursor.execute("SELECT * FROM Users")
    users = cursor.fetchall()
    return {
        'statusCode': 200,
        'body': json.dumps(users)
    }

def insert_user(mydb, cursor, user, password):
    insert_query = "INSERT INTO Users(usuario, contraseña) VALUES (%s, %s)"
    cursor.execute(insert_query, (user, password))
    mydb.commit()
    select_users(cursor)
    return {
        'statusCode': 200,
        'body': json.dumps("User inserted")
    }
```