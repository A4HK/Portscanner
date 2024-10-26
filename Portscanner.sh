#!/bin/bash
#Made by A4HK
# Definir colores
rojo="\e[31m"
verde="\e[32m"
amarillo="\e[33m"
azul="\e[34m"
reset="\e[0m"

# Manejar Ctrl+C
trap 'echo -e "\n${rojo}[-] Script detenido con Control + C${reset}"; exit' SIGINT

# Función para mostrar la ayuda
mostrar_ayuda() {
    echo -e "${azul}Uso: $0 <puerto_inicial> <puerto_final> <red/máscara>${reset}"
    echo -e "${azul}Ejemplo: $0 80 90 192.168.1.0/24${reset}"
    echo ""
    echo -e "${verde}Este script comprueba si un rango de puertos está abierto en un rango de direcciones IP.${reset}"
    echo -e "${verde}Los parámetros son los siguientes:${reset}"
    echo -e "  <puerto_inicial>  ${reset}El puerto inicial a comprobar (debe estar entre 1 y 65535)."
    echo -e "  <puerto_final>    ${reset}El puerto final a comprobar (debe estar entre 1 y 65535)."
    echo -e "  <red/máscara>     ${reset}La red y la máscara en formato CIDR (ej. 192.168.1.0/24)."
    echo ""
    echo -e "${amarillo}Opciones:${reset}"
    echo -e "  -h                ${azul}Muestra esta ayuda.${reset}"
    exit 0
}

# Función para validar la IP
validar_ip() {
    local ip="$1"
    if [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
        if [[ "$i1" -ge 0 && "$i1" -le 255 && "$i2" -ge 0 && "$i2" -le 255 &&
              "$i3" -ge 0 && "$i3" -le 255 && "$i4" -ge 0 && "$i4" -le 255 ]]; then
            return 0
        fi
    fi
    return 1
}

# Función para validar la máscara de red
validar_mascara() {
    local mascara="$1"
    if [[ "$mascara" -ge 0 && "$mascara" -le 32 ]]; then
        return 0
    fi
    return 1
}

# Función para validar el rango de puertos
validar_puertos() {
    local puerto_inicial="$1"
    local puerto_final="$2"
    if [[ "$puerto_inicial" -ge 1 && "$puerto_inicial" -le 65535 &&
          "$puerto_final" -ge 1 && "$puerto_final" -le 65535 &&
          "$puerto_inicial" -le "$puerto_final" ]]; then
        return 0
    fi
    return 1
}

# Función para verificar si la IP está activa
ping_ip() {
    ping -c 1 -W 1 "$1" >/dev/null 2>&1
    return $?
}

# Comprobar si se pasa el parámetro de ayuda
if [ "$#" -eq 1 ] && [ "$1" == "-h" ]; then
    mostrar_ayuda
fi

# Validar número de argumentos
if [ "$#" -ne 3 ]; then
    echo -e "${rojo}Uso: $0 <puerto_inicial> <puerto_final> <red/máscara>${reset}"
    echo -e "${rojo}Ejemplo: $0 80 90 192.168.1.0/24${reset}"
    exit 1
fi

# Leer parámetros
puerto_inicial=$1
puerto_final=$2
red_mas=$3

# Validar rango de puertos
validar_puertos "$puerto_inicial" "$puerto_final"
if [ $? -ne 0 ]; then
    echo -e "${rojo}[-] Error: Rango de puertos inválido. Debe estar entre 1 y 65535 y el puerto inicial debe ser menor o igual que el puerto final.${reset}"
    exit 1
fi

# Separar red y máscara
IFS='/' read -r red mascara <<< "$red_mas"

# Validar IP y máscara
validar_ip "$red"
if [ $? -ne 0 ]; then
    echo -e "${rojo}[-] Error: Dirección IP inválida.${reset}"
    exit 1
fi

validar_mascara "$mascara"
if [ $? -ne 0 ]; then
    echo -e "${rojo}[-] Error: Máscara inválida. Debe estar entre 0 y 32.${reset}"
    exit 1
fi

# Calcular el rango de IPs
IFS='.' read -r i1 i2 i3 i4 <<< "$red"
ip_base="$i1.$i2.$i3"
n_ips=$(( 2 ** (32 - mascara) - 2 ))  # Excluir red y broadcast

# Escaneo de IPs y puertos
for i in $(seq 1 "$n_ips"); do
    ip="$ip_base.$i"
    ping_ip "$ip"
    
    if [ $? -ne 0 ]; then
        echo -e "${amarillo}[!] IP $ip no está activa, pasando a la siguiente...${reset}"
        continue
    fi

    echo -e "${azul}[*] Escaneando IP activa: $ip${reset}"
    for puerto in $(seq "$puerto_inicial" "$puerto_final"); do
        (echo > /dev/tcp/$ip/$puerto) >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo -e "${verde}[+] Puerto $puerto está abierto en $ip${reset}"
        fi
    done
done
