#!/bin/bash

#Define códigos de escape ANSI
vermelho='\033[0;31m'
verde='\033[0;32m'
amarelo='\033[0;33m'
amarelo_negrito='\033[1;33m'
NC='\033[0m' # No Color
azul='\033[0;34m'
verde_negrito='\033[1;32m'
azul_negrito='\033[1;34m'

#Informações do script
echo
V="v1.1 Ping Sweep - Identifying Active Hosts"
PROPRIETARIO="Danilo A. Rêgo"
LINK_REPOSITORIO="https://github.com/D11-Gith/"

# Função para exibir o banner
print_banner() {
    echo -e "${amarelo_negrito}"
    figlet -f big "Ping Sweep"
    echo
    echo -e "${V}"
    echo -e "Owner: ${PROPRIETARIO}"
    echo -e "Repository: ${LINK_REPOSITORIO}${NC}"
}

#Chamada da função para exibir o banner
print_banner
#Função para exibir a barra de progresso
barra_progresso() {
    local total=$1
    local atual=0
    local progresso=""
    local percent=0

    #Calcula e exibe a barra de progresso
    while [ $atual -le $total ]; do
        percent=$(( (atual * 100) / total ))
        progresso=$(printf "%-${total}s" "#" | sed 's/ /#/g' | head -c $atual)
        printf "${verde_negrito}Progress: [%s>%s]${NC} %d%%\r" "$progresso" "$(printf "%-$((total - atual))s")" $percent
        sleep 0.1  # Pausa para animar a barra
        ((atual++))
    done
    echo  # Nova linha após completar a barra
}
 Defina o total de unidades de progresso (exemplo: 100 unidades)
total=50
echo #Quebra uma linha

#Verifica se o usuário forneceu a rede como argumento ou entra em modo interativo
if [ $# -ne 1 ]; then
    echo -e "${amarelo_negrito}No argument provided. Entering interactive mode...${NC}"
    echo
    echo -n -e "${azul_negrito}Enter the target network (example: 192.168.1):${NC} "
    read rede
else
    rede="$1"
fi
echo
echo -e "${azul_negrito}**********************************************************************************${NC}"
echo -e "${azul_negrito}*                                                                                *${NC}"
echo -e "${azul_negrito}*           [+] Performing Ping Sweep on network:${verde_negrito} -> ${rede}.X <-  ${NC}           ${azul_negrito}*${NC}"
echo -e "${azul_negrito}*                                                                                *${NC}"
echo -e "${azul_negrito}**********************************************************************************${NC}"
echo
#Arquivo de saída
output_file="icmp.txt"
> "$output_file"  #Limpa o arquivo antes de começar

#Loop de 1 a 254 para escanear todos os IPs da sub-rede
count=0
for ip in {1..254}; do
    alvo="${rede}.$ip"
    resultado=$(ping -c 1 -W 1 "$alvo" | grep "icmp_seq=")

    if [ -n "$resultado" ]; then
        echo "$alvo" >> "$output_file"
        echo -e "${verde_negrito}[✓] Host Responding to ICMP${NC} -> ${azul}$alvo${NC}"
        let "count++"
    fi
done
echo
# Chama a função de barra de progresso
barra_progresso $total
#Exibe o resumo final
echo
echo -e "${amarelo_negrito}[+] Scan completed! Total responding hosts: ${NC}${verde_negrito}$count${NC}"
echo -e "${amarelo_negrito}[+] Results saved in${NC} -> ${verde_negrito}${output_file}${NC}"
