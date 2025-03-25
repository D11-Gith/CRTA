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

V="v1.2 Netcat - Verifying Open Ports with Logging"
OWNER="Danilo A. Rêgo"
REPOSITORY_LINK="https://github.com/D11-Gith/"
LOG_FILE="netcat_scan_$(date +%Y%m%d_%H%M%S).log"
TIMEOUT=3  # Timeout for connections (user-adjustable)

# Checks if the required commands are installed
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

# Call the function to display the banner
print_banner

# If no arguments are passed, enter interactive mode
if [ $# -lt 2 ]; then
    echo -e "${yellow}No arguments passed. Entering interactive mode...${NC}"
    echo
    echo -ne "${bold_blue}[+] Enter the target IP or domain:${NC} "
    read -r ip

    echo -ne "${bold_blue}[+] Enter the ports to test or provide a .txt file with the list:${NC} "
    read -r port_input

    # Check if the input is a .txt file or a list of entered ports
    if [[ -f "$port_input" ]]; then
        mapfile -t ports < "$port_input"
        echo -e "${bold_green}[✓] File detected! Ports loaded from the file:${NC} ${ports[*]}"
    else
        IFS=' ' read -ra ports <<< "$port_input"
    fi
else
    ip="$1"
    shift
    ports=("$@")
fi

echo
# Display target information
log_result "${bold_green}[✓]${NC}${bold_blue} Target${NC} -> ${bold_green}$ip${NC}"
log_result "${bold_green}[✓]${NC}${bold_blue} Ports to test${NC} -> ${bold_green}${ports[*]}${NC}"
echo # Blank line for organization

# Testing connection for each port
for port in "${ports[@]}"; do
    log_result "${bold_yellow}[+] Testing connection on $ip:$port${NC}"

    # Try to connect using netcat (nc) with configurable timeout
    result=$(echo -e "whoami" | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null)

    if [ -n "$result" ]; then
        log_result "${bold_green}[✓] Connection successful on $ip:$port${NC}"

        # Run additional commands only if connection is successful
        log_result "${bold_blue}[>] Executing remote pwd...${NC}"
        result=$(echo -e "pwd" | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null)
        log_result "$result"

        log_result "${bold_blue}[>] Executing remote hostname...${NC}"
        result=$(echo -e "hostname" | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null)
        log_result "$result"

        log_result "${bold_blue}[>] Executing remote whoami...${NC}"
        result=$(echo -e "whoami" | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null)
        log_result "$result"

        log_result "${bold_blue}[>] Executing remote ls...${NC}"
        result=$(echo -e "ls" | nc -w "$TIMEOUT" "$ip" "$port" 2>/dev/null)
        log_result "$result"

    else
        log_result "${red}[X] Connection failed on $ip:$port${NC}"
    fi
    echo # Blank line for organization
done

echo -e "${bold_blue}[!] Results saved in: ${NC}${bold_green}$LOG_FILE${NC}"
