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