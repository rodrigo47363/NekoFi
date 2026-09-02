# NekoFi.sh - Framework Automatizado de Auditoría y Pentesting Wi-Fi

[![GitHub Release](https://img.shields.io/github/v/release/rodrigo47363/NekoFi?style=flat-square)](https://github.com/rodrigo47363/NekoFi/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg?style=flat-square)](https://github.com/rodrigo47363/NekoFi/blob/main/LICENSE)
[![Platform: Linux](https://img.shields.io/badge/Platform-Parrot%20%7C%20Kali%20%7C%20Debian-brightgreen.svg?style=flat-square)]()
[![Hashcat: Mode 22000](https://img.shields.io/badge/Hashcat-Mode%2022000%20(WPA/WPA2/PMKID)-orange.svg?style=flat-square)]()
![Bash](https://img.shields.io/badge/Language-Bash-4EAA25?style=flat-square&logo=gnu-bash)

**Versión 2.0 (Refactored)** | *Suite de Auditoría Inalámbrica Todo-en-Uno*

<img src="https://i.imgur.com/neko_wifi.png" width="280" align="right" alt="NekoFi Logo">

**NekoFi.sh** es un framework integral en Bash diseñado para operadores de Red Team y auditores de seguridad que buscan automatizar flujos de reconocimiento, captura de hashes y explotación sobre redes inalámbricas (802.11).

Integra herramientas de bajo nivel para captura de paquetes, ataques WPS (PixieDust / PIN Brute Force), análisis offline de Handshakes WPA/WPA2 y conversión directa al formato unificado **Hashcat Modo 22000**.

---

## 🔍 Características Principales

* **Reconocimiento y Detección de APs:** Escaneo activo de puntos de acceso con WPS habilitado mediante `wash`.
* **Captura de PMKID y Handshakes:** Captura en caliente con `hcxdumptool` y extracción automatizada de hashes `.22000` vía `hcxtools` (`hcxpcapngtool`).
* **Ataques WPS Automatizados:** Explotación de WPS vulnerable usando `reaver` (soporte PixieDust `-K 1`) y `bully`.
* **Ataques por Diccionario WPA/WPA2:** Evaluación offline con `aircrack-ng` sobre archivos de captura `.cap`/`.pcap`.
* **Crackeo GPU con Hashcat:** Compatibilidad nativa con **Hashcat modo 22000** (`WPA-PBKDF2-PMKID+EAPOL`).
* **Generación de Diccionarios y Tablas PMK:** Creación de listas de palabras con `crunch` y cálculo de hashes precomputados con `cowpatty`.
* **Gestión Segura de Interfaces:** Conmutación rápida entre modo *Monitor* y *Managed* con control de procesos conflictivos (`airmon-ng check kill` / `iw`).

---

## ⚙️ Requisitos del Sistema

| Categoría | Herramientas Integradas |
| :--- | :--- |
| **Control de Redes & Hardware** | `iw`, `iproute2`, `pciutils`, `usbutils`, `rfkill`, `ethtool`, `macchanger` |
| **Captura y Análisis 802.11** | `aircrack-ng`, `wash`, `hcxdumptool`, `hcxtools` (`hcxpcapngtool`) |
| **Explotación WPS & WPA** | `reaver`, `pixiewps`, `bully`, `wifite` |
| **Cracking & Diccionarios** | `hashcat`, `john`, `crunch`, `cowpatty` |
| **Servicios Auxiliares** | `hostapd`, `dnsmasq`, `lighttpd`, `tmux`, `xterm` |

> 📌 *El script verifica e instala automáticamente las dependencias faltantes en distribuciones basadas en Debian (Parrot OS, Kali Linux, Ubuntu).*

---

## 🚀 Instalación y Ejecución

```bash
# 1. Clonar el repositorio
git clone https://github.com/rodrigo47363/NekoFi.git
cd NekoFi

# 2. Asignar permisos de ejecución
chmod +x NekoFi.sh

# 3. Ejecutar como superusuario (requiere permisos root)
sudo ./NekoFi.sh
```

---

## 🖥️ Menú Interactivo (v2.0)

```text
########################################################
#                                                      #
#                  NekoFi.sh                           #
#                  Versión 2.0 (Refactored)            #
#                                                      #
#  GitHub: https://github.com/rodrigo47363/NekoFi      #
#  Autor:  rodrigo47363                                #
########################################################

  Interfaz activa: wlan0 | Modo: wlan0mon

  [1]  Escanear redes Wi-Fi (Wash / WPS)
  [2]  Capturar Handshake / PMKID (hcxdumptool)
  [3]  Ataque WPS con Reaver / PixieWPS
  [4]  Ataque WPS con Bully
  [5]  Ataque WPA/WPA2 por Diccionario (Aircrack-ng)
  [6]  Crackear contraseñas con Hashcat (Modo 22000)
  [7]  Crear diccionario con Crunch
  [8]  Crear tabla PMK con Cowpatty
  [9]  Poner interfaz en modo Monitor
  [10] Poner interfaz en modo Managed
  [11] Cambiar / Redetectar interfaz Wi-Fi
  [12] Actualizar NekoFi.sh desde GitHub
  [0]  Salir
```

---

## 🛠️ Flujo Táctico de Operación

### 1. 📡 Escaneo y Captura de PMKID (Clientless Attack)
```bash
Seleccione una opción: 2
[*] Poniendo wlan0 en modo monitor...
[*] Capturando PMKID / Handshakes con hcxdumptool...
[*] Extrayendo hashes WPA/WPA2/PMKID con hcxtools...
[✔] ¡Hashes capturados con éxito en: pmkid_20260902_024500.22000!
```

### 2. ⚡ Crackeo Acelerado por GPU con Hashcat
```bash
Seleccione una opción: 6
Ruta del archivo de hashes: pmkid_20260902_024500.22000
Ruta del diccionario: /usr/share/wordlists/rockyou.txt
[+] Iniciando Hashcat (Modo 22000)...
```

---

## 🔄 Actualización Automática
Seleccione la opción **`12`** en el menú principal para sincronizar automáticamente el script con la última versión publicada en la rama `main` de GitHub.

---

## 📜 Licencia y Descargo de Responsabilidad

Distribuido bajo la licencia **[MIT](https://github.com/rodrigo47363/NekoFi/blob/main/LICENSE)**.

> ⚠️ **Aviso de Uso Ético:** Este software está diseñado exclusivamente para propósitos educativos, auditorías de seguridad autorizadas y prácticas en entornos de laboratorio controlados. El uso de esta herramienta contra infraestructuras sin consentimiento previo por escrito es ilegal.

---

## 📬 Contacto
* **Autor:** [rodrigo47363](https://github.com/rodrigo47363)
* **Reportar Issues:** [https://github.com/rodrigo47363/NekoFi/issues](https://github.com/rodrigo47363/NekoFi/issues)


