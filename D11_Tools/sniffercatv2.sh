#!/bin/bash

# ANSI color definitions
green='\033[0;32m'
red='\033[1;31m'
blue='\033[0;34m'
yellow='\033[1;33m'
NC='\033[0m' # No Color
bold_green='\033[1;32m'
bold_blue='\033[1;34m'
bold_yellow='\033[1;33m'

V="v2.0 Netcat - Interactive Bind Shell"
OWNER="Danilo A. Rêgo"
REPOSITORY_LINK="https://github.com/D11-Gith/"
LOG_FILE="netcat_scan_$(date +%Y%m%d_%H%M%S).log"
TIMEOUT=3  # Timeout for connections (user-adjustable)

# Check if required commands are installed
for cmd in nc figlet host; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${red}[X] Error: The command '$cmd' is not installed!${NC}"
        exit 1
    fi
done

# Function to display the banner
print_banner() {
    echo -e "${bold_yellow}"
    figlet -f big "Sniffer Cat"
    echo -e "${V}"
    echo -e "Owner: ${OWNER}"
    echo -e "Repository: ${REPOSITORY_LINK}${NC}"
    echo
}

# Logs result
log_result() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Function to display the menu
menu_principal() {
    echo -e "${bold_green}[+] Escolha uma categoria de comandos:${NC}"
    echo
    echo -e "${bold_green}1)${NC} ${bold_blue}Comandos de Identidade e Usuário${NC}"
    echo -e "${bold_green}2)${NC} ${bold_blue}Comandos de Manipulação de Arquivos e Diretórios${NC}"
    echo -e "${bold_green}3)${NC} ${bold_blue}Comandos de Rede${NC}"
    echo -e "${bold_green}4)${NC} ${bold_blue}Comandos de Sistema e Processos${NC}"
    echo -e "${bold_green}5)${NC} ${bold_blue}Sair${NC}"
    echo -ne "${bold_blue}[>] Escolha uma opção:${NC} "
}

menu_comandos() {
    local categoria="$1"
    case "$categoria" in
        1)
            echo -e "${bold_green}Comandos de Identidade e Usuário:${NC}"
            echo -e "1) whoami"
            echo -e "2) id"
            echo -e "3) groups"
            echo -e "4) hostname"
            echo -e "5) Voltar ao Menu Principal"
            ;;
        2)
            echo -e "${bold_green}Comandos de Manipulação de Arquivos e Diretórios:${NC}"
            echo -e "1) pwd"
            echo -e "2) ls -la"
            echo -e "3) cat /etc/passwd"
            echo -e "4) du -sh *"
            echo -e "5) Voltar ao Menu Principal"
            ;;
        3)
            echo -e "${bold_green}Comandos de Rede:${NC}"
            echo -e "1) ifconfig"
            echo -e "2) ip a"
            echo -e "3) netstat -tulnp"
            echo -e "4) ss -tulnp"
            echo -e "5) Voltar ao Menu Principal"
            ;;
        4)
            echo -e "${bold_green}Comandos de Sistema e Processos:${NC}"
            echo -e "1) uname -a"
            echo -e "2) ps aux"
            echo -e "3) df -h"
            echo -e "4) uptime"
            echo -e "5) Voltar ao Menu Principal"
            ;;
    esac
    echo -ne "${bold_blue}[>] Escolha uma opção:${NC} "
}

executar_comando() {
    local cmd="$1"
    echo -e "${bold_blue}[>] Executando remoto: ${cmd}${NC}"
    resultado=$(echo -e "$cmd" | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null)
    log_result "$resultado"
}

# Call the function to display the banner
print_banner

# Interactive mode
if [ $# -eq 0 ]; then
    echo -e "${bold_yellow}No arguments passed. Entering interactive mode...${NC}"
    echo
    echo -ne "${bold_blue}[+] Insira o IP de destino:${NC} "
    read -r ip

    echo -ne "${bold_blue}[+] Insira as portas a serem testadas (ou forneça um arquivo .txt):${NC} "
    read -r ports_input

    if [[ -f "$ports_input" ]]; then
        echo -e "${bold_green}[✓] Arquivo detectado! Carregando portas do arquivo...${NC}"
        mapfile -t ports < "$ports_input"
    else
        IFS=',' read -ra ports <<< "$ports_input"
    fi
else
    ip="$1"
    shift
    ports=("$@")
fi

# Test connections and execute commands
declare -A active_connections

for port in "${ports[@]}"; do
    echo -e "${bold_yellow}[+] Testing connection on $ip:$port...${NC}"
    result=$(echo -e "whoami" | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null)

    if [ -n "$result" ]; then
        log_result "${bold_green}[✓] Connection successful on $ip:$port${NC}"
        active_connections["$ip:$port"]=1
    else
        log_result "${red}[X] Connection failed on $ip:$port${NC}"
    fi
done

# If there are successful connections, let the user choose which one to interact with
if [ ${#active_connections[@]} -gt 0 ]; then
    echo -e "${bold_green}[+] Conexões bem-sucedidas detectadas:${NC}"
    select connection in "${!active_connections[@]}"; do
        if [ -n "$connection" ]; then
            ip_port=(${connection//:/ })
            ip="${ip_port[0]}"
            port="${ip_port[1]}"
            echo -e "${bold_blue}[+] Selecionado: $connection${NC}"

            # Now let the user interact with the menu
            while true; do
                menu_principal
                read -r escolha

                case "$escolha" in
                    1)
                        while true; do
                            menu_comandos 1
                            read -r cmd_escolha
                            case "$cmd_escolha" in
                                1) executar_comando "whoami" ;;
                                2) executar_comando "id" ;;
                                3) executar_comando "groups" ;;
                                4) executar_comando "hostname" ;;
                                5) break ;;
                                *) echo -e "${red}[X] Opção inválida!${NC}" ;;
                            esac
                        done
                        ;;
                    2)
                        while true; do
                            menu_comandos 2
                            read -r cmd_escolha
                            case "$cmd_escolha" in
                                1) executar_comando "pwd" ;;
                                2) executar_comando "ls -la" ;;
                                3) executar_comando "cat /etc/passwd" ;;
                                4) executar_comando "du -sh *" ;;
                                5) break ;;
                                *) echo -e "${red}[X] Opção inválida!${NC}" ;;
                            esac
                        done
                        ;;
                    3)
                        while true; do
                            menu_comandos 3
                            read -r cmd_escolha
                            case "$cmd_escolha" in
                                1) executar_comando "ifconfig" ;;
                                2) executar_comando "ip a" ;;
                                3) executar_comando "netstat -tulnp" ;;
                                4) executar_comando "ss -tulnp" ;;
                                5) break ;;
                                *) echo -e "${red}[X] Opção inválida!${NC}" ;;
                            esac
                        done
                        ;;
                    4)
                        while true; do
                            menu_comandos 4
                            read -r cmd_escolha
                            case "$cmd_escolha" in
                                1) executar_comando "uname -a" ;;
                                2) executar_comando "ps aux" ;;
                                3) executar_comando "df -h" ;;
                                4) executar_comando "uptime" ;;
                                5) break ;;
                                *) echo -e "${red}[X] Opção inválida!${NC}" ;;
                            esac
                        done
                        ;;
                    5)
                        echo -e "${bold_red}[!] Encerrando conexão...${NC}"
                        exit 0
                        ;;
                    *)
                        echo -e "${red}[X] Opção inválida!${NC}"
                        ;;
                esac
            done
        else
            echo -e "${red}[X] Opção inválida!${NC}"
        fi
    done
else
    echo -e "${red}[X] Nenhuma conexão bem-sucedida foi detectada.${NC}"
    exit 1
fi
