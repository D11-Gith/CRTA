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
    figlet -f big "ProwlShell"
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
    echo -e "${bold_green}[+] Choose a command category:${NC}"
    echo
    echo -e "${bold_green}1)${NC} ${bold_blue}Identity and User Commands${NC}"
    echo -e "${bold_green}2)${NC} ${bold_blue}File and Directory Manipulation Commands${NC}"
    echo -e "${bold_green}3)${NC} ${bold_blue}Network Commands${NC}"
    echo -e "${bold_green}4)${NC} ${bold_blue}System and Process Commands${NC}"
    echo -e "${bold_green}5)${NC} ${bold_blue}Exit${NC}"
    echo
    echo -ne "${bold_blue}[>] Choose an option:${NC} "
}

menu_comandos() {
    local categoria="$1"
    echo
    case "$categoria" in
        1)
            echo -e "${bold_green}Identity and User Commands:${NC}"
            echo -e "${bold_green}1)${NC}${bold_blue} whoami${NC}"
            echo -e "${bold_green}2)${NC}${bold_blue} id${NC}"
            echo -e "${bold_green}3)${NC}${bold_blue} groups${NC}"
            echo -e "${bold_green}4)${NC}${bold_blue} hostname${NC}"
            echo -e "${bold_green}5)${NC}${bold_blue} Back to Main Menu${NC}"
            ;;
        2)
            echo -e "${bold_green}File and Directory Manipulation Commands:${NC}"
            echo -e "${bold_green}1)${NC}${bold_blue} pwd${NC}"
            echo -e "${bold_green}2)${NC}${bold_blue} ls -la${NC}"
            echo -e "${bold_green}3)${NC}${bold_blue} cat /etc/passwd${NC}"
            echo -e "${bold_green}4)${NC}${bold_blue} du -sh *"
            echo -e "${bold_green}5)${NC}${bold_blue} Back to Main Menu${NC}"
            ;;
        3)
            echo -e "${bold_green}Network Commands:${NC}"
            echo -e "${bold_green}1)${NC}${bold_blue} ifconfig${NC}"
            echo -e "${bold_green}2)${NC}${bold_blue} ip a${NC}"
            echo -e "${bold_green}3)${NC}${bold_blue} netstat -tulnp${NC}"
            echo -e "${bold_green}4)${NC}${bold_blue} ss -tulnp${NC}"
            echo -e "${bold_green}5)${NC}${bold_blue} Back to Main Menu${NC}"
            ;;
        4)
            echo -e "${bold_green}System and Process Commands:${NC}"
            echo -e "${bold_green}1)${NC}${bold_blue} uname -a${NC}"
            echo -e "${bold_green}2)${NC}${bold_blue} ps aux${NC}"
            echo -e "${bold_green}3)${NC}${bold_blue} df -h${NC}"
            echo -e "${bold_green}4)${NC}${bold_blue} uptime${NC}"
            echo -e "${bold_green}5)${NC}${bold_blue} Back to Main Menu${NC}"
            ;;
    esac
    echo
    echo -ne "${bold_green}[>] Choose an option:${NC} "
}

executar_comando() {
    local cmd="$1"
    echo -e "${bold_green}[>] Executing remotely: ${cmd}${NC}"
    resultado=$(echo -e "$cmd" | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null)
    log_result "$resultado"
    echo
}

# Call the function to display the banner
print_banner

# Interactive mode
if [ $# -eq 0 ]; then
    echo -e "${bold_yellow}No arguments passed. Entering interactive mode...${NC}"
    echo
    echo -ne "${bold_blue}[+] Enter the target IP:${NC} "
    read -r ip

    echo -ne "${bold_blue}[+] Enter the ports to be tested (or provide a .txt file):${NC} "
    read -r ports_input

    # If a file is detected, load the ports and display the message
    if [[ -f "$ports_input" ]]; then
        echo -e "${bold_green}[✓] File detected! Ports loaded from the file: $(cat "$ports_input" | tr '\n' ' ')${NC}"
        mapfile -t ports < "$ports_input"
    else
        IFS=',' read -ra ports <<< "$ports_input"
    fi

    # Display target IP and ports to be tested
    echo
    echo -e "${bold_green}[✓]${NC}${bold_blue} Target${NC} -> ${bold_green}$ip${NC}"
    echo -e "${bold_green}[✓]${NC}${bold_blue} Ports to test${NC} ->  ${bold_green}${ports[*]}${NC}"
    sleep 3
    echo
else
    ip="$1"
    shift
    ports=("$@")
fi

# Test the connections and display results for each port individually
declare -A active_connections

for port in "${ports[@]}"; do
    echo -e "${bold_yellow}[+] Testing connection on $ip:$port...${NC}"
    result=$(echo -e "whoami" | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null)

    if [ -n "$result" ]; then
        log_result "${bold_green}[✓] Connection successful on $ip:$port${NC}"
        active_connections["$ip:$port"]=1
        echo
    else
        log_result "${red}[X] Connection failed on $ip:$port${NC}"
        echo
    fi
done

# If there are successful connections, let the user choose which one to interact with
if [ ${#active_connections[@]} -gt 0 ]; then
    echo -e "${bold_green}[+] Successful connections detected:${NC}"
    echo
    echo -e "${bold_green}[>] Choose an option${NC}"
    select connection in "${!active_connections[@]}"; do
        if [ -n "$connection" ]; then
            ip_port=(${connection//:/ })
            ip="${ip_port[0]}"
            port="${ip_port[1]}"
            echo -e "${bold_green}[+] Selected: $connection${NC}"
            echo

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
                                *) echo -e "${red}[X] Invalid option!${NC}" ;;
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
                                *) echo -e "${red}[X] Invalid option!${NC}" ;;
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
                                *) echo -e "${red}[X] Invalid option!${NC}" ;;
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
                                *) echo -e "${red}[X] Invalid option!${NC}" ;;
                            esac
                        done
                        ;;
                    5)
                        echo -e "${bold_yellow}[!] Closing connection...${NC}"
                        sleep 3
                        exit 0
                        ;;
                    *)
                        echo -e "${red}[X] Invalid option!${NC}"
                        ;;
                esac
            done
        else
            echo -e "${red}[X] Invalid option!${NC}"
        fi
    done
else
    echo -e "${red}[X] No successful connections detected.${NC}"
    exit 1
fi
