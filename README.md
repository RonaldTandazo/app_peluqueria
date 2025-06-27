# app_peluqueria

Una vez clonado el proyecto desde GitHub, debe seguir los siguientes pasos:

1. Ejecutar el comando: flutter pub get, esto instalará las dependencias necesarias para el correcto funcionamiento del proyecto

2. Debe crear un archivo llamdo .env tomando como ejemplo el archivo: .example.env Deben incluirse las siguientes variables: 
    - BACKEND_URL: corresponde a la url y puerto donde se encuentra levantado el proyecto del backend, debe agregarse: /api despues del puerto ya que el backend espera ese sufijo en las rutas existentes

    Notas: 
    - Pueden tomarse los valores indicados en el archivo .example.env

3. Luego deberá conectar un dispositivo android mediante usb y habilitar la transferencia de archivos

4. Posteriormete deberá habilitar el modo desarrollador en el dispositivo.

5. Una vez realizados todos los pasos anteriores deberá ejecutar el siguiente comando en la terminal: flutter run, esto hará que el proyecto se instale en el dispositivo conectado

Nota: Si tiene el proyecto de backend clonado en su pc deberá verificar que el proyecto este actualizado, ejecutando este comando: git pull origin main en una terminal dentro de la ruta del proyecto del backend   