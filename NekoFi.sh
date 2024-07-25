#!/bin/bash

# Ocultar el cursor
tput civis

# Función para mostrar un frame de la animación
display_frame() {
    local text=("$@")
    local rows=${#text[@]}
    local cols=${#text[0]}
    local start_row=$(( ( $(tput lines) - rows ) / 2 ))
    local start_col=$(( ( $(tput cols) - cols ) / 2 ))

    clear
    for (( i=0; i<rows; i++ )); do
        tput cup $(( start_row + i )) $start_col
        echo -e "${text[$i]}"
    done
    sleep 0.5
}

# Función para mostrar la animación de gato
mostrar_animacion() {
    local animation_name="animation" # Nombre del directorio de animación
    
    cd "$animation_name" || exit
    local frames=$(cat frameList)
    
    while true; do
        for frame in $frames; do
            frameText=()
            while IFS= read -r line; do
                frameText+=("$line")
            done < "$frame"
            display_frame "${frameText[@]}"
        done
    done
}

# Función para mostrar banner
mostrar_banner() {
    echo "##############################################"
    echo "#                                            #"
    echo "#             NekoFi.sh                      #"
    echo "#             Versión 1.0                    #"
    echo "#                                            #"
    echo "##############################################"
    echo
}

# Función para mostrar el menú de opciones
mostrar_menu() {
    echo "Seleccione una opción:"
    echo "1. Escanear redes WiFi"
    echo "2. Cracking de contraseñas"
    echo "3. Mostrar animación de gato"
    echo "4. Salir"
}

# Función para escanear redes WiFi
escaneo_redes() {
    echo "Escaneando redes WiFi..."
    animacion_puntos "Buscando redes" 5
    # Aquí iría el código para escanear redes WiFi
}

# Función para cracking de contraseñas
cracking_contrasenas() {
    echo "Iniciando el cracking de contraseñas..."
    animacion_puntos "Cracking en progreso" 5
    # Aquí iría el código para cracking de contraseñas
}

# Función para evaluar vulnerabilidades
evaluar_vulnerabilidades() {
    echo "Evaluando vulnerabilidades..."
    # Aquí iría el código para evaluar vulnerabilidades
}

# Animación de puntos
animacion_puntos() {
    local -r texto="$1"
    local -r duracion=$2
    local -r intervalo=0.5
    local -r fin=$((SECONDS + duracion))
    
    while [ $SECONDS -lt $fin ]; do
        for i in "" "." ".." "..."; do
            echo -ne "\r$texto$i"
            sleep $intervalo
        done
    done
    echo
}

# Función principal que gestiona el menú
main() {
    mostrar_banner
    while true; do
        mostrar_menu
        read -p "Ingrese su opción: " opcion
        case $opcion in
            1)
                escaneo_redes
                ;;
            2)
                cracking_contrasenas
                ;;
            3)
                mostrar_animacion
                ;;
            4)
                echo "Saliendo..."
                tput cnorm
                exit 0
                ;;
            *)
                echo "Opción inválida, por favor intente de nuevo."
                ;;
        esac
        echo
    done
}

# Ejecutar la función principal
main
