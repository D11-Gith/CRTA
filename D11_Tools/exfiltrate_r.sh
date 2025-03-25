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

V="v1.2 Netcat - File Exfiltration"
OWNER="Danilo A. Rêgo"
REPOSITORY_LINK="https://github.com/D11-Gith/"
LOG_FILE="file_exfiltration_$(date +%Y%m%d_%H%M%S).log"
TIMEOUT=3  # Timeout for connections (user-adjustable)

# Checks if the required commands are installed
for cmd in nc figlet; do
    if ! command -v "$cmd" &> /dev/null; then
        echo -e "${red}[X] Error: The command '$cmd' is not installed!${NC}"
        exit 1
    fi
done

# Function to display the banner
print_banner() {
    echo -e "${bold_yellow}"
    figlet -f big "ExfilCat"
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
    echo -ne "${bold_blue}[+] Enter the port to listen on for receiving file (default 4444):${NC} "
    read -r port_input
    port=${port_input:-4444}

    echo -ne "${bold_blue}[+] Enter the file to save the received content as:${NC} "
    read -r file_path

else
    port="$1"
    file_path="$2"
fi

echo
# Display target information
log_result "${bold_green}[✓]${NC}${bold_blue} Listening on Port${NC} -> ${bold_green}$port${NC}"
log_result "${bold_green}[✓]${NC}${bold_blue} File to save${NC} -> ${bold_green}$file_path${NC}"
echo # Blank line for organization

# Listening for the incoming file using netcat
log_result "${bold_yellow}[+] Waiting for file to be received on port $port...${NC}"
nc -l -p "$port" > "$file_path"

if [ $? -eq 0 ]; then
    log_result "${bold_green}[✓] File received successfully and saved as '$file_path'!${NC}"
else
    log_result "${red}[X] Error during file reception.${NC}"
fi

# Display the saved log
echo -e "${bold_blue}[!] Results saved in: ${NC}${bold_green}$LOG_FILE${NC}"
