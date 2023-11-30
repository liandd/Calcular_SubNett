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