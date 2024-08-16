# NekoFi.sh

**Versión 1.4**

[![GitHub Release](https://img.shields.io/github/v/release/rodrigo47363/NekoFi)](https://github.com/rodrigo47363/NekoFi/releases)
[![License](https://img.shields.io/github/license/rodrigo47363/NekoFi)](https://github.com/rodrigo47363/NekoFi/blob/main/LICENSE)
[![Issues](https://img.shields.io/github/issues/rodrigo47363/NekoFi)](https://github.com/rodrigo47363/NekoFi/issues)

NekoFi.sh es un script de Bash diseñado para facilitar diversas tareas de auditoría y pruebas de seguridad en redes WiFi. Con NekoFi.sh, puedes escanear redes, capturar handshakes y realizar ataques WPS y WPA/WPA2, entre otras funcionalidades.

## Características

- **Escaneo de redes WiFi** usando `wash`
- **Captura de handshakes (WPS/PMKID)** con `hcxdumptool`
- **Ataques WPS** con `Reaver`, `PixieWPS`, y `Bully`
- **Ataques WPA/WPA2** con diccionarios
- **Ataques WEP**
- **Creación de diccionarios** con `Crunch` y `Cowpatty`
- **Gestión de modo monitor y managed** para interfaces de red
- **Actualización automática** desde GitHub

## Requisitos

NekoFi.sh requiere las siguientes herramientas:

- `iw`
- `aircrack-ng`
- `xterm`
- `tmux`
- `iproute2`
- `pciutils`
- `usbutils`
- `rfkill`
- `wget`
- `ccze`
- `x11-xserver-utils`
- `systemd`
- `hashcat`
- `reaver`
- `hcxdumptool`
- `john`
- `pixiewps`
- `bully`
- `cowpatty`
- `crunch`
- `wash`
- `procps`
- `airgeddon`

El script verifica e instala automáticamente estas herramientas si no están presentes en el sistema.

## Instalación

Para instalar y ejecutar NekoFi.sh, sigue estos pasos:

1. **Clona el repositorio:**

    ```bash
    git clone https://github.com/rodrigo47363/NekoFi.git
    cd NekoFi
    chmod +x NekoFi.sh
    ```

2. **Ejecuta el script con permisos de superusuario:**

    ```bash
    sudo ./NekoFi.sh
    ```

## Uso

Al ejecutar NekoFi.sh, se presentará un menú con las siguientes opciones:

1. **Escanear redes WiFi**: Usa `wash` para escanear redes WiFi disponibles.
2. **Capturar Handshake (WPS/PMKID)**: Usa `hcxdumptool` para capturar handshakes WPS/PMKID.
3. **Ataque WPS con Reaver**: Ataca redes con WPS usando `Reaver`.
4. **Ataque WPS con PixieWPS**: Ataca redes con WPS usando `PixieWPS`.
5. **Ataque WPS con Bully**: Ataca redes con WPS usando `Bully`.
6. **Ataque WPA/WPA2**: Realiza un ataque WPA/WPA2 usando un diccionario.
7. **Ataque WEP**: Realiza un ataque WEP.
8. **Crear diccionario con Crunch**: Crea un diccionario de contraseñas con `Crunch`.
9. **Crear diccionario personalizado con Cowpatty**: Crea un diccionario personalizado con `Cowpatty`.
10. **Crackear contraseñas con Hashcat**: Utiliza `hashcat` para crackear contraseñas usando un diccionario.
11. **Poner interfaz en modo monitor**: Cambia la interfaz seleccionada al modo monitor.
12. **Poner interfaz en modo managed**: Cambia la interfaz seleccionada al modo managed.
13. **Salir**: Cierra el script.
14. **Actualizar NekoFi.sh desde GitHub**: Descarga la última versión del script desde GitHub.
15. **Convertir .cap a .hccapx**: Convierte un archivo `.cap` a `.hccapx`.
0. **Ayuda**: Muestra esta ayuda.

### Ejemplo de Uso

1. **Escanear Redes WiFi**

    Selecciona la opción `1` para escanear redes WiFi. El script pondrá la interfaz seleccionada en modo monitor y ejecutará `wash` para listar las redes disponibles.

2. **Capturar Handshake (WPS/PMKID)**

    Selecciona la opción `2` para capturar handshakes WPS/PMKID. El script pondrá la interfaz en modo monitor, ejecutará `hcxdumptool` y extraerá los PMKIDs capturados.

3. **Ataque WPS con Reaver**

    Selecciona la opción `3`, ingresa el BSSID y el canal de la red objetivo, y el script ejecutará `reaver` para iniciar el ataque WPS.

Para más detalles, selecciona la opción `0` en el menú para ver la ayuda completa.

## Actualización del Script

Para actualizar `NekoFi.sh` a la última versión, selecciona la opción 14 en el menú. El script descargará la versión más reciente desde GitHub y reemplazará la versión actual.

## Contribuciones

Las contribuciones son bienvenidas. Si encuentras un problema o tienes una sugerencia, abre un [issue](https://github.com/rodrigo47363/NekoFi/issues) o envía un pull request.

## Licencia

Este proyecto está licenciado bajo la [Licencia MIT](LICENSE).

## Contacto

Para más información, visita mi perfil de GitHub: [rodrigo47363](https://github.com/rodrigo47363)
