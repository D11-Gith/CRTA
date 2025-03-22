# Ferramentas de Suporte ao Exame - CRTA - Red Team Analyst

Este repositório contém ferramentas desenvolvidas com base no laboratório prático do curso CRTA - Red Team Analyst. O objetivo principal dessas ferramentas é ajudar os estudantes a se prepararem para o exame, facilitando a execução de tarefas e simulando cenários práticos abordados durante o curso.

## Objetivo

As ferramentas foram criadas para fornecer suporte prático na identificação e exploração de redes e sistemas. Elas foram inspiradas nos desafios do laboratório, visando aumentar a compreensão sobre as práticas de segurança cibernética, redes, pentesting, entre outros, e para facilitar a execução de tarefas no ambiente do exame.

# 1. Ping Sweep - Identifying Active Hosts
   
O Ping Sweep é uma ferramenta simples para realizar uma varredura ICMP (ping) em uma rede e identificar quais hosts estão ativos. O script verifica os hosts na rede especificada e exibe os resultados, além de salvar os hosts ativos em um arquivo de saída. Ele também oferece uma barra de progresso animada para indicar o andamento da varredura.

Funcionalidades:

- Realiza um ping sweep em uma rede para identificar hosts ativos.

- Exibe os hosts respondendo ao ICMP.

- Salva os resultados de hosts ativos em um arquivo de saída (icmp.txt).

- Exibe uma barra de progresso durante a execução da varredura.

- Exibe um banner informativo com o nome do script, versão, proprietário e link do repositório.

Pré-requisitos:
  - Este script depende de ferramentas que já devem estar instaladas no seu sistema. Se você ainda não as tiver, instale com os seguintes comandos (dependendo da sua distribuição Linux):

sudo apt update
sudo apt install figlet

Como Usar:
 - Modo Interativo: Se você não fornecer a rede como argumento, o script entra no modo interativo e solicita que você insira a rede a ser escaneada.

$ ./ping_sweep.sh
No argument provided. Entering interactive mode...
Enter the target network (example: 192.168.1): 192.168.1

Modo Não-Interativo (Com Argumentos): Você pode passar a rede diretamente como argumento.
- $ ./ping_sweep.sh 192.168.1

Como Funciona:
- O script solicita a rede alvo (ex: 192.168.1) no modo interativo ou usa o argumento passado para realizar a varredura.

- O script realiza um ping para cada IP de 1 a 254 na sub-rede fornecida.

- Para cada host que responder ao ping, o script exibe uma mensagem de sucesso e registra o IP no arquivo de saída (icmp.txt).

- Uma barra de progresso animada é exibida durante a execução.

- Ao final, o script exibe um resumo com a quantidade total de hosts ativos e o local do arquivo de saída.

Exemplo de saída:

- [✓] Host Responding to ICMP -> 192.168.1.1
- [✓] Host Responding to ICMP -> 192.168.1.2
- [+] Scan completed! Total responding hosts: 5
- [+] Results saved in -> icmp.txt

##
# 2. SnifferCat - Verificação de Portas Abertas com Registro de Log
    
O SnifferCat foi desenvolvido para verificar portas abertas em um alvo especificado e realizar interações de teste, como whoami, pwd e ls, registrando os resultados em um arquivo de log.

Como Usar:
- Clonar o repositório: git clone https://github.com/[seu_usuario]/[repositorio].git

Funcionalidades:

- Verificação de portas abertas em um IP ou domínio fornecido.

- Execução de comandos remotos, como whoami, hostname, pwd, ls, entre outros.

- Busca de arquivos sensíveis no sistema remoto.

- Suporte a CipherTunnel para estabelecer conexões seguras.

- Registro de todos os resultados em um arquivo de log.

Pré-requisitos:

- Antes de executar o SnifferCat, você precisa garantir que os seguintes comandos estão instalados:

- sudo apt update
- sudo apt install netcat figlet locate host

Como Usar:

- Modo Interativo: Se você não fornecer argumentos ao script, ele entrará no modo interativo.

- $ ./sniffer_cat.sh
- [+] Enter the target IP or domain: example.com
- [+] Enter the ports to test or provide a .txt file with the list: 80 443 8080

Modo Não-Interativo (Com Argumentos): Você pode passar diretamente os argumentos.

- $ ./sniffer_cat.sh example.com 80 443 8080

Como Funciona:

- O script solicita que o usuário insira o IP/dominio alvo e as portas a serem verificadas.

- Para cada porta fornecida, o script tenta estabelecer uma conexão via Netcat.

- Se a conexão for bem-sucedida, o script executa uma série de comandos no sistema remoto.

- O script registra todos os resultados em um arquivo de log.

Exemplo de saída:

- [✓] Target -> example.com
- [✓] Ports to test -> 80 443 8080
- [+] Testing connection on example.com:80
- [✓] Connection successful on example.com:80
- [>] Executing pwd... /home/user
- [>] Executing hostname... server.local
- [>] Executing whoami... user
- [>] Executing ls... file1.txt file2.conf secret_key.pem
- [!] Results saved in: netcat_scan_20230315_133000.log
##
# 3. SSH Tunnel - Secure Connection Manager
Versão: v1.0
Proprietário: Danilo A. Rêgo
Repositório: GitHub

Descrição:

- Este script é uma ferramenta para estabelecer túneis SSH seguros entre um host local e um destino remoto, permitindo o redirecionamento de portas (port forwarding) através de um túnel SSH. O script oferece uma maneira simples e interativa de criar conexões seguras, com log de atividades e controle básico de erro.

Funcionalidades:

- Estabelece um túnel SSH entre uma máquina local e um destino remoto.

- Suporta redirecionamento de portas (Local Port Forwarding).

- Armazena logs detalhados das conexões e falhas.

- Valida as portas de rede para garantir que os valores passados sejam válidos.

Como Usar:

- Modo Interativo: Se nenhum argumento for fornecido, o script pedirá informações para configurar o túnel.

- ./ssh_tunnel.sh

Modo Linha de Comando:

- ./ssh_tunnel.sh 8080 example.com user 80 192.168.1.10

Requisitos:

- ssh: Cliente SSH

- figlet: Para exibir o banner (opcional)

- Instalar dependências (caso necessário):

- sudo apt install openssh-client figlet

Considerações Finais:

Essas ferramentas foram desenvolvidas para auxiliar na preparação para o exame CRTA, simulando atividades práticas que os estudantes poderão encontrar durante a avaliação. Elas cobrem áreas essenciais como varredura de redes, verificação de portas abertas, e estabelecimento de conexões seguras via SSH.

Sugestões de Melhoria:

Adicionar opções de configuração mais avançadas para personalização das ferramentas.

Incluir scripts de automação para integração com outras ferramentas de pentesting, como Metasploit ou Nmap.

Fornecer opções de relatórios automatizados para facilitar a análise dos resultados.


