#!/bin/bash

# Definição de cores ANSI
verde='\033[0;32m'
vermelho='\033[1;31m'
azul='\033[0;34m'
amarelo='\033[1;33m'
NC='\033[0m' # No Color
verde_negrito='\033[1;32m'
azul_negrito='\033[1;34m'
amarelo_negrito='\033[1;33m'

V="v1.0 SSH Tunnel - Secure Connection Manager"
PROPRIETARIO="Danilo A. Rêgo"
LINK_REPOSITORIO="https://github.com/D11-Gith/"
LOG_FILE="ssh_tunnel_$(date +%Y%m%d_%H%M%S).log"

# Habilita interrupção no caso de erro crítico
set -e

# Verifica se o SSH está instalado
if ! command -v ssh &> /dev/null; then
    echo -e "${vermelho}[X] Error: The 'ssh' command is not installed!${NC}"
    exit 1
fi

# Verifica se o figlet está instalado e exibe banner
print_banner() {
    echo -e "${amarelo_negrito}"
    if command -v figlet &> /dev/null; then
        figlet -f big "Cipher Tunnel"
    else
        echo "===== Cipher Tunnel ====="
    fi
    echo -e "${V}"
    echo -e "Owner: ${PROPRIETARIO}"
    echo -e "Repository: ${LINK_REPOSITORIO}${NC}"
    echo
}

# Registra log
log_result() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Chamada da função para exibir o banner
print_banner

# Função para validar portas
validar_porta() {
    if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 1 ] || [ "$1" -gt 65535 ]; then
        echo -e "${vermelho}[X] Error: Porta inválida ($1). Use um valor entre 1 e 65535.${NC}"
        exit 1
    fi
}

# Se nenhum argumento for passado, entra em modo interativo
if [ $# -lt 5 ]; then
    echo -e "${amarelo_negrito} No argument provided. Interactive mode activated...${NC}"
    echo
    echo -ne "${azul_negrito}[+] Enter the local port for the tunnel:${NC} "
    read -r local_port
    validar_porta "$local_port"

    echo -ne "${azul_negrito}[+] Enter the SSH host (IP or domain):${NC} "
    read -r ssh_host

    echo -ne "${azul_negrito}[+] Enter the SSH user:${NC} "
    read -r ssh_user

    echo -ne "${azul_negrito}[+] Enter the forwarding port (destination):${NC} "
    read -r dest_port
    validar_porta "$dest_port"

    echo -ne "${azul_negrito}[+] Enter the destination host (forwarding):${NC} "
    read -r dest_host
else
    local_port="$1"
    ssh_host="$2"
    ssh_user="$3"
    dest_port="$4"
    dest_host="$5"
    validar_porta "$local_port"
    validar_porta "$dest_port"
fi
echo

# Exibindo resumo antes de iniciar o túnel
log_result "${azul_negrito}Establishing SSH tunnel...${NC}"
echo
log_result "${verde_negrito}[✓] Local Port:${NC} $local_port"
log_result "${verde_negrito}[✓] SSH Host:${NC} $ssh_host"
log_result "${verde_negrito}[✓] User:${NC} $ssh_user"
log_result "${verde_negrito}[✓] Forwarding Port:${NC} $dest_port"
log_result "${verde_negrito}[✓] Destination Host:${NC} $dest_host"
echo

# Executa o túnel SSH em segundo plano
ssh -N -L "$local_port:$dest_host:$dest_port" "$ssh_user@$ssh_host" -o ConnectTimeout=10 &>> "$LOG_FILE" &
SSH_PID=$!

# Função para encerrar túnel ao sair
trap "echo -e '${vermelho}[!] Encerrando túnel SSH (PID: $SSH_PID)...${NC}'; kill $SSH_PID" EXIT

# Aguarda alguns segundos para verificar se o túnel está ativo
sleep 2
if pgrep -f "ssh -N -L $local_port:$dest_host:$dest_port" > /dev/null; then
    log_result "${verde_negrito}[✓] Túnel SSH estabelecido com sucesso! PID: $SSH_PID${NC}"
    echo -e "${azul_negrito}[!] Para encerrar, pressione CTRL+C.${NC}"
else
    log_result "${vermelho}[X] Failed to establish SSH tunnel.${NC}"
    exit 1
fi

# Mantém o script rodando enquanto o túnel estiver ativo
wait $SSH_PID
