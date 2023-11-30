#!/bin/bash
# Autor: liandd (Juan Garcia)
##Colours
greenColour="\e[0;32m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m"
blueColour="\e[0;34m"
yellowColour="\e[0;33m"
purpleColour="\e[0;35m"
turquoiseColour="\e[0;36m"
grayColour="\e[0;37m"

# Ctrl_C
trap ctrl_c INT

function ctrl_c(){
    echo -e "\n\n${redColour}[!] Saliendo...${endColour}\n"
    tput cnorm && exit 1
}

function helpPanel(){
    echo -e "\n${yellowColour}[!]${endColour}${grayColour} Uso: ${endColour}${greenColour}$0${endColour} ${purpleColour}-i${endColour}${blueColour} <ipAddress>${endColour} ${purpleColour}-n${endColour} ${blueColour}<netMask>${endColour}\n"
    echo -e "\t${purpleColour}i)${endColour}${grayColour} Direccion${endColour}${blueColour} IPv4${endColour}${grayColour} para subnet${endColour}"
    echo -e "\t${purpleColour}n)${endColour}${grayColour} Mascara de red${endColour}"
    echo -e "\t${purpleColour}h)${endColour}${grayColour} Panel de ayuda${endColour}"
}

function binaryRepresentation(){
    IFS='.' read -r -a ipOctet <<< "$1"
    IFS='.' read -r -a netOctet <<< "$2"
    local ipBinary=""
    local netBinary=""
    for octet in "${ipOctet[@]}"; do
        binaryOctet=$(echo "obase=2; $octet" | bc)
        binaryOctet=$(printf "%08d" "$binaryOctet")
        ipBinary+="$binaryOctet."
    done 
    ipBinary=${ipBinary%?}
    for octet in "${netOctet[@]}"; do
        binaryOctet=$(echo "obase=2; $octet" | bc)
        binaryOctet=$(printf "%08d" "$binaryOctet")
        netBinary+="$binaryOctet."
    done
    netBinary=${netBinary%?}
    ipBIN=$ipBinary
    netBIN=$netBinary
    echo -e "\n${greenColour}[!]${endColour}${grayColour} Representacion Binaria:${endColour}"
    echo -e "\n${yellowColour}[+]${endColour}${greenColour} IP Address dada: ${endColour}${purpleColour}$(printf '%s.' "${ipBIN}" | sed "s/\.$//")${endColour} "
    echo -e "${yellowColour}[+]${endColour}${turquoiseColour} Mascara de Red: ${endColour}${purpleColour}$(printf '%s.' "${netBIN}" | sed "s/\.$//")${endColour} "
}

function getOctetosMask(){
    mask="$1"
    IFS='.' read -r -a octetosMask <<< "$mask"
    maskEnRango=()
    if [ "${#octetosMask[@]}" -eq 4 ]; then
        for octeto in "${octetosMask[@]}"; do
            if [ "$octeto" == 0 ] || [ "$octeto" == 128 ] || [ "$octeto" == 192 ] || [ "$octeto" == 224 ] || [ "$octeto" == 240 ] || [ "$octeto" == 248 ] || [ "$octeto" == 252 ] || [ "$octeto" == 254 ] || [ "$octeto" == 255 ]; then
                maskEnRango+=("true")
            else
                maskEnRango+=("false")
            fi
        done
        if [ "${maskEnRango[0]}" == "true" ] && [ "${maskEnRango[1]}" == "true" ] && [ "${maskEnRango[2]}" == "true" ] && [ "${maskEnRango[3]}" == "true" ]; then
            return 0
        else
            echo -e "\n${redColour}[!] Mascaras de subnet solo usan${endColour}${greenColour} 2^${endColour}${yellowColour}[${endColour}${turquoiseColour}0${endColour}${grayColour}-${endColour}${turquoiseColour}7${endColour}${yellowColour}]${endColour}${grayColour}.${endColour}${redColour} Ingresa nuevamente la mascara.${endColour}\n\n"
            exit 1
        fi
        else
            echo -e "\n${redColour}[!] Ingresar los cuatro octetos para la mascara de red usando puntos${endColour}\n"
            exit 1
        fi
}

function getOctetosDeIP(){
    ip="$1"
    IFS='.' read -r -a octetosIP <<< "$ip"
    ipEnRango=()
    if [ "${#octetosIP[@]}" -eq 4 ]; then
        for octeto in "${octetosIP[@]}"; do
            if [ "$octeto" -ge 0 ] && [ "$octeto" -le 255 ]; then
                ipEnRango+=("true")
            else
                ipEnRango+=("false")
            fi
        done
        if [ "${ipEnRango[0]}" == "true" ] && [ "${ipEnRango[1]}" == "true" ] && [ "${ipEnRango[2]}" == "true" ] && [ "${ipEnRango[3]}" == "true" ]; then
            return 0
        else
            echo -e "\n${redColour}[!] Solo hay${endColour}${greenColour} 255 bits${endColour}${blueColour} por octeto${endColour}${grayColour}.${endColour}${redColour} Ingresa nuevamente la IP.${endColour}\n\n"
            exit 1
        fi
    else
        echo -e "\n${redColour}[!] Ingresar los cuatro octetos para la IP usando puntos${endColour}\n\n"
        exit 1
    fi
}

function calcularClase(){
    local octetosIP=("${!1}")
    counter=0 
    if [ "${octetosIP[0]}" == 10 ]; then
        counter=1  # Class A Private address blocks
    elif [ "${octetosIP[0]}" == 172 ] && [ "${octetosIP[1]}" -ge 16 ] && [ "${octetosIP[1]}" -le 31 ]; then
        counter=2  # Class B Private address blocks
    elif [ "${octetosIP[0]}" == 192 ] && [ "${octetosIP[1]}" == 168 ]; then
        counter=3  # Class C Private address blocks
    elif [ "${octetosIP[0]}" == 127 ]; then
        counter=4  # Loopback Address Reserved address blocks
    elif [ "${octetosIP[0]}" -ge 0 ] && [ "${octetosIP[0]}" -lt 127 ]; then
        counter=5
    elif [ "${octetosIP[0]}" -gt 127 ] && [ "${octetosIP[0]}" -lt 192 ]; then
        counter=6
    elif [ "${octetosIP[0]}" -gt 191 ] && [ "${octetosIP[0]}" -lt 224 ]; then
        counter=7
    elif [ "${octetosIP[0]}" -gt 223 ] && [ "${octetosIP[0]}" -lt 240 ]; then
        counter=8
    elif [ "${octetosIP[0]}" -gt 239 ] && [ "${octetosIP[0]}" -le 255 ]; then
        counter=9
    else
        counter=0  # Out of Range
    fi
    case $counter in
        1) echo -e "\n${yellowColour}[+]${endColour}${grayColour} IP Class:${endColour}${purpleColour} Private block${endColour},${greenColour} Class 'A'${endColour}" ;;
        2) echo -e "\n${yellowColour}[+]${endColour}${grayColour} IP Class:${endColour}${purpleColour} Private block${endColour},${greenColour} Class 'B'${endColour}" ;;
        3) echo -e "\n${yellowColour}[+]${endColour}${grayColour} IP Class:${endColour}${purpleColour} Private block${endColour},${greenColour} Class 'C'${endColour}" ;;
        4) echo -e "\n${yellowColour}[+]${endColour}${grayColour} IP Class:${endColour}${redColour} Reserved block, System Loopback Address${endColour}" ;;
        5) echo -e "\n${yellowColour}[+]${endColour}${grayColour} IP Class:${endColour}${greenColour} A${endColour}" ;;
        6) echo -e "\n${yellowColour}[+]${endColour}${grayColour} IP Class:${endColour}${greenColour} B${endColour}" ;;
        7) echo -e "\n${yellowColour}[+]${endColour}${grayColour} IP Class:${endColour}${greenColour} C${endColour}" ;;
        8) echo -e "\n${yellowColour}[+]${endColour}${grayColour} IP Class:${endColour}${greenColour} D${endColour}"
            echo -e "\n${redColour}[!]${endColour}${grayColour} Esta es una ${endColour}${greenColour}Clase D${endColour}${redColour} Reservada${endColour}${turquoiseColour} 'Multicast IP Address Block'${endColour}" ;;
        9) echo -e "\n${yellowColour}[+]${endColour}${grayColour} IP Class:${endColour}${greenColour} E${endColour}"
            echo -e "\n${redColour}[!]${endColour}${grayColour} Esta es una ${endColour}${greenColour}Clase E${endColour}${redColour} Reservada${endColour}${turquoiseColour} 'Multicast IP Address Block'${endColour}" ;;
        *) echo -e "\n${redColour}[!]${endColour}${grayColour} No esta en rango${endColour}" ;;
    esac
}

function getNetID(){
    local octetosIP=("${!1}")
    local octetosMask=("${!2}")
    for ((j = 0; j < ${#octetosIP[@]}; j++)); do
        if [ $j -gt 0 ]; then
            printf ""
        fi
        netID+=("$((octetosIP[j] & octetosMask[j]))")
    done
}

function getNetIDRange(){
    local -a netIDEnd=() 
    IFS='.' read -r -a decimalNetID <<< "$1"
    local netInc=$2
    IFS='.' read -r -a decimalMask <<< "$3"
    for ((i=0; i<${#decimalNetID[@]}; i++)); do
        if [ "${decimalMask[i]}" -eq 255 ]; then
            netIDEnd+=("${decimalNetID[i]}")
        elif [ "${decimalMask[i]}" -lt 255 ] && [ "${decimalMask[i]}" -gt 0 ]; then
            netIDEnd+=("$(( (decimalNetID[i] | (255 - decimalMask[i])) + netInc - 1))")
        else
            netIDEnd+=("255")
        fi
    done
    echo -e "${yellowColour}[+]${endColour}${grayColour} BroadCast IP: ${endColour}${blueColour}$(printf '%s.' "${netIDEnd[@]}" | sed 's/\.$//')${endColour}"
}

while getopts "i:n:h" arg; do
    case $arg in
        i) ipAddress=$OPTARG;;
        n) netMask=$OPTARG;;
        h) ;;
    esac
done
if [ $ipAddress ] && [ $netMask ]; then
    calculoSubnet "$ipAddress" "$netMask"
else
    helpPanel
fi