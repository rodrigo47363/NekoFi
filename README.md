Claro, aquí tienes un README profesional para tu script `NekoFi.sh`:

---

# NekoFi.sh

[![NekoFi](https://img.shields.io/badge/NekoFi-1.0-brightgreen)](https://github.com/rodrigo47363/NekoFi)
[![License](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

NekoFi.sh es una herramienta avanzada y automatizada para realizar auditorías de seguridad en redes WiFi. Diseñada para pentesters y entusiastas de la ciberseguridad, NekoFi.sh ofrece diversas opciones de ataque para evaluar la seguridad de redes inalámbricas.

## Características

- **Instalación Automática de Herramientas:** Verifica e instala todas las herramientas necesarias.
- **Modo Monitor:** Administra automáticamente el modo monitor de la interfaz inalámbrica.
- **Varias Opciones de Ataque:**
  - Escaneo de redes WiFi
  - Captura de Handshake (WPS/PMKID)
  - Ataques WPS con Reaver, PixieWPS y Bully
  - Ataques WPA/WPA2
  - Ataques WEP
  - Creación de diccionarios personalizados con Crunch y Cowpatty
- **Menú Interactivo:** Fácil de usar con opciones claras y detalladas.

## Requisitos

- **Sistema Operativo:** Linux (probado en Debian/Ubuntu)
- **Privilegios de Superusuario:** Algunas funciones requieren permisos de superusuario.

## Instalación

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/rodrigo47363/NekoFi.git
   cd NekoFi
   ```

2. **Dar permisos de ejecución:**
   ```bash
   chmod +x NekoFi.sh
   ```

3. **Ejecutar el script:**
   ```bash
   sudo ./NekoFi.sh
   ```

## Uso

Al ejecutar `NekoFi.sh`, se presentará un menú interactivo con las siguientes opciones:

1. **Escanear redes WiFi:** Utiliza wash para escanear redes WiFi disponibles.
2. **Capturar Handshake (WPS/PMKID):** Usa hcxdumptool para capturar handshakes WPS/PMKID.
3. **Ataque WPS con Reaver:** Ataca redes con WPS usando Reaver.
4. **Ataque WPS con PixieWPS:** Ataca redes con WPS usando PixieWPS.
5. **Ataque WPS con Bully:** Ataca redes con WPS usando Bully.
6. **Ataque WPA/WPA2:** Realiza un ataque WPA/WPA2 usando un diccionario.
7. **Ataque WEP:** Realiza un ataque WEP.
8. **Crear diccionario con Crunch:** Crea un diccionario de contraseñas con Crunch.
9. **Crear diccionario personalizado con Cowpatty:** Crea un diccionario personalizado con Cowpatty.
10. **Salir:** Cierra el script.
0. **Ayuda:** Muestra ayuda detallada sobre las opciones disponibles.

## Ejemplo de Uso

### Escaneo de Redes WiFi

Para escanear redes WiFi disponibles:

1. Seleccione la opción "1. Escanear redes WiFi" en el menú.
2. El script iniciará el modo monitor y utilizará wash para listar las redes disponibles.

### Captura de Handshake (WPS/PMKID)

Para capturar un handshake:

1. Seleccione la opción "2. Capturar Handshake (WPS/PMKID)" en el menú.
2. El script iniciará el modo monitor y usará hcxdumptool para capturar los handshakes.

### Ataque WPA/WPA2

Para realizar un ataque WPA/WPA2:

1. Seleccione la opción "6. Ataque WPA/WPA2" en el menú.
2. Ingrese el BSSID y el canal de la red objetivo.
3. Proporcione la ruta a un diccionario de contraseñas.
4. El script realizará el ataque y tratará de descifrar la contraseña usando aircrack-ng.

## Contribuciones

Las contribuciones son bienvenidas. Por favor, siga estos pasos para contribuir:

1. **Fork el repositorio.**
2. **Cree una nueva rama (feature/nueva-caracteristica).**
3. **Realice sus cambios.**
4. **Envíe un pull request.**

## Licencia

Este proyecto está bajo la licencia MIT. Vea el archivo [LICENSE](LICENSE) para más detalles.

## Contacto

Rodrigo  
[GitHub](https://github.com/rodrigo47363) | [Portafolio Web](https://rodrigo47363.github.io)
