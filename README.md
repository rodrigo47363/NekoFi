# NekoFi.sh - Herramienta de Auditoría WiFi

[![GitHub Release](https://img.shields.io/github/v/release/rodrigo47363/NekoFi?style=flat-square)](https://github.com/rodrigo47363/NekoFi/releases)
[![License](https://img.shields.io/github/license/rodrigo47363/NekoFi?color=blue&style=flat-square)](https://github.com/rodrigo47363/NekoFi/blob/main/LICENSE)
[![Issues](https://img.shields.io/github/issues/rodrigo47363/NekoFi?style=flat-square)](https://github.com/rodrigo47363/NekoFi/issues)
![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=flat-square&logo=gnu-bash)

**Versión 1.4** | *Auditoría WiFi todo-en-uno*

<img src="https://i.imgur.com/neko_wifi.png" width="300" align="right" alt="NekoFi Logo">

NekoFi.sh es un script avanzado de Bash diseñado para simplificar pruebas de seguridad y auditorías en redes WiFi. Integra múltiples herramientas de pentesting WiFi en una interfaz unificada, permitiendo desde escaneo básico hasta ataques avanzados con un solo comando.

## 🔍 Características Principales

- **Escaneo de redes WiFi** con detección de vulnerabilidades
- **Captura de handshakes** (WPS/PMKID) usando `hcxdumptool`
- **Ataques WPS** con soporte para:
  - Reaver
  - PixieWPS
  - Bully
- **Ataques WPA/WPA2** con diccionarios personalizables
- **Ataques WEP** integrados
- **Generación de diccionarios** con Crunch y Cowpatty
- **Gestión automática de interfaces** (modo monitor/managed)
- **Actualización automática** desde repositorio GitHub
- **Conversión de formatos** (.cap a .hccapx)

## ⚙️ Requisitos del Sistema

| Categoría           | Herramientas Requeridas                                                                 |
|---------------------|----------------------------------------------------------------------------------------|
| Básicas             | `iw`, `aircrack-ng`, `xterm`, `tmux`, `iproute2`, `pciutils`, `usbutils`, `rfkill`     |
| Pentesting WiFi     | `hashcat`, `reaver`, `hcxdumptool`, `pixiewps`, `bully`, `cowpatty`, `wash`, `airgeddon`|
| Utilidades          | `wget`, `ccze`, `x11-xserver-utils`, `systemd`, `john`, `crunch`, `procps`             |
| Desarrollo          | `libcap-dev`                                                                           |

> 📌 El script verifica e instala automáticamente las dependencias faltantes

## 🚀 Instalación

```bash
# Clonar repositorio
git clone https://github.com/rodrigo47363/NekoFi.git
cd NekoFi

# Dar permisos de ejecución
chmod +x NekoFi.sh

# Ejecutar (requiere root)
sudo ./NekoFi.sh
```

## 🖥️ Menú de Interfaz

```
==========================================
    NEKOFI.sh - (v1.4) by rodrigo47363
==========================================
1) Escanear redes WiFi
2) Capturar Handshake (WPS/PMKID)
3) Ataque WPS con Reaver
4) Ataque WPS con PixieWPS
5) Ataque WPS con Bully
6) Ataque WPA/WPA2
7) Ataque WEP
8) Crear diccionario con Crunch
9) Crear diccionario con Cowpatty
10) Crackear contraseñas con Hashcat
11) Modo monitor
12) Modo managed
13) Salir
14) Actualizar script
15) Convertir .cap a .hccapx
0) Ayuda
==========================================
```

## 🛠️ Ejemplos de Uso

### 🔎 Escaneo de Redes
```bash
Seleccione opción: 1
[*] Poniendo interfaz wlan0 en modo monitor...
[*] Escaneando redes con Wash...
```

### 🔓 Ataque WPS con Reaver
```bash
Seleccione opción: 3
[+] Ingrese BSSID objetivo: AA:BB:CC:DD:EE:FF
[+] Ingrese canal: 6
[*] Iniciando ataque WPS con Reaver...
```

### 🗝️ Craqueo con Hashcat
```bash
Seleccione opción: 10
[?] Ruta del archivo .hccapx: captures/target.hccapx
[?] Ruta del diccionario: wordlists/rockyou.txt
[*] Iniciando craqueo...
```

## 🔄 Actualización
Seleccione la opción **14** en el menú principal para actualizar automáticamente a la última versión:
```bash
[*] Actualizando NekoFi.sh...
[+] Descargando última versión desde GitHub...
[!] Actualización completada!
```

## 🤝 Contribuciones
Las contribuciones son bienvenidas:
1. Reporta bugs mediante [issues](https://github.com/rodrigo47363/NekoFi/issues)
2. Envía Pull Requests con mejoras
3. Sugiere nuevas características

## 📜 Licencia
Distribuido bajo [Licencia MIT](https://github.com/rodrigo47363/NekoFi/blob/main/LICENSE)

## 📬 Contacto
- **Autor**: rodrigo47363
- **GitHub**: [https://github.com/rodrigo47363](https://github.com/rodrigo47363)
- **Reportar Issues**: [https://github.com/rodrigo47363/NekoFi/issues](https://github.com/rodrigo47363/NekoFi/issues)

