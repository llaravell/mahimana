#! /bin/bash

# Color codes
# Reset
NC='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White

# Check if the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${Red}This script must be run as root!${NC}"
    exit 1
fi

# Define a function to display my logo
displayLogo() {
    printf "${BIGreen}"
    cat << "EOF"
  __  __       _     _ __  __                   
 |  \/  |     | |   (_)  \/  |                  
 | \  / | __ _| |__  _| \  / | __ _ _ __   __ _ 
 | |\/| |/ _` | '_ \| | |\/| |/ _` | '_ \ / _` |
 | |  | | (_| | | | | | |  | | (_| | | | | (_| |
 |_|  |_|\__,_|_| |_|_|_|  |_|\__,_|_| |_|\__,_|
                                                
                                                
EOF
    printf "${NC}"
}

# Update and upgrade the system
updateAndUpgrade() {
    printf "${Blue} 🚀 Starting Update and upgrade the system ... ${NC} \n";
    {
        apt-get update > /dev/null 2>&1 && apt-get upgrade -y > /dev/null 2>&1 & spinner;
        printf "${Green} 🎉 Update and Upgrade the system is complete ${NC} \n";
        # wait 5 secound
        sleep 5;
        main;
    } || {
        printf "${RED}❌ An error occurred while updating the system ${NC}\n";
        exit 1;
    }
}

# Find SSH port and return
FindSSHPort() {
    # Check if ssh is installed
    if command -v ssh &> /dev/null; then
        # Check if sshd_config file not exists
        if [ ! -f /etc/ssh/sshd_config ]; then
            echo "SSH is not installed";
            exit 1;
        fi
        # Find port in sshd_config
        port=$(grep "#\?Port" /etc/ssh/sshd_config | head -1 | awk '{print $2}')
        echo "Current port is $port";
        exit 0;
    else
        echo "SSH is not installed";
        exit 1;
    fi
}

# Change SSh port
changeSSHPort() {
    {
        # Check ssh and sshd is installed
        dpkg -s ssh > /dev/null 2>&1 || {
            printf "${Blue} 🚀 Starting Install SSH ... ${NC} \n";
            apt-get install -y ssh > /dev/null 2>&1 & spinner;
            printf "${Green} 🎉 Install SSH is complete ${NC} \n";
            }
        read -p "Enter the new SSH port: " new_port
        printf "${Blue} 🚀 Starting Change SSH port ... ${NC} \n";
        # Find old port in sshd_config
        old_port=$(grep "#\?Port" /etc/ssh/sshd_config | head -1 | awk '{print $2}')
        # Replace old port with new port in sshd_config
        sed -i -E "s/^#?Port\s+[0-9]+$/Port ${new_port}/" /etc/ssh/sshd_config
        printf "${Green} 🎉 Change SSH port is complete ${NC} \n";
        service ssh restart > /dev/null 2>&1 & spinner;
        printf "${Green} 🎉 SSH service is restarted ${NC} \n";
        printf "${Green} 🎉 SSH port is changed to $new_port ${NC} \n";
        # check if ufw is installed
        if command -v ufw &> /dev/null; then
            printf "${Blue} 🚀 Starting Close Firewall for old port... ${NC} \n";
            ufw deny $old_port > /dev/null 2>&1 & spinner;
            printf "${Green} 🎉 Firewall is closed sucessfully ${NC} \n";
            printf "${Blue} 🚀 Starting Open Firewall ... ${NC} \n";
            ufw allow $new_port > /dev/null 2>&1 & spinner;
            printf "${Green} 🎉 Firewall is opened sucessfully ${NC} \n";
        fi
        # wait 5 secound
        sleep 5;
        main;

    } || {
        printf "${RED}❌ An error occurred while changing SSH port ${NC}\n";
        exit 1;
    }
}

# Bind a domain to server by bind9
BindDomain() {
        # If Bind9 not installed then install
        if ! command -v bind &> /dev/null; then
            printf "${Blue} 🚀 Installing bind9 ... ${NC} \n";
            apt-get install -y bind9 > /dev/null 2>&1 & spinner;
            printf "${Green} 🎉 Install bind9 is complete ${NC} \n";
        fi
        # Starting bind 9
        printf "${Blue} 🚀 Starting Bind9 ... ${NC} \n";
        systemctl start bind9 > /dev/null 2>&1 & spinner;
        printf "${Green} 🎉 Bind9 is running ${NC} \n";
        # Enabling bind 9
        printf "${Blue} 🚀 Enabling Bind9 ... ${NC} \n";
        systemctl enable bind9 > /dev/null 2>&1 & spinner;
        printf "${Green} 🎉 Bind9 is enabled ${NC} \n";
        # get domain 
        read -p "Enter the domain: " domain
        domainWithoutExtension="${domain%.*}"
        # Set the domain in /etc/bind/named.conf.local
        printf "${Blue} 🚀 Setting the domain... ${NC} \n";
        namedConfLocal="include "/etc/bind/zone/${domain}/${domainWithoutExtension}.conf";";
        echo "$namedConfLocal" > /etc/bind/named.conf.local;
        namedConfLocalSave="include "/etc/bind/zone/${domain}/${domainWithoutExtension}.conf";";
        echo "$namedConfLocalSave" > /etc/bind/named.conf.local.save;
        # make directory zone and make directory with name of domain
        # Check if directory exists
        if [ -d /etc/bind/zone ]; then
            rm -r /etc/bind/zone > /dev/null 2>&1 & spinner;
        fi
        mkdir -p /etc/bind/zone > /dev/null 2>&1 & spinner;
        mkdir -p /etc/bind/zone/${domain} > /dev/null 2>&1 & spinner;
        #create file with name domain without extension
        touch /etc/bind/zone/${domain}/${domainWithoutExtension}.conf;
        # Get Ip
        ip=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1);
        reverseIp=$(echo "$ip" | awk -F '.' '{print $4 "." $3 "." $2 "." $1}');
        reverseIpWithoutLastDot=$(echo $reverseIp | sed 's/\.[^.]*$//')
        reverseIpLastDot=$(echo $reverseIp | awk -F'.' '{print $4}')
        domainWithoutExtensionConf="
zone "${domain}" {
    type master;
    file "/etc/bind/zone/${domain}/db.${domainWithoutExtension}";
};
zone "${reverseIpWithoutLastDot}.in-addr.arpa" {
    type master;
    file "/etc/bind/zone/${domain}/db.${reverseIpLastDot}";
};
"
        echo "$domainWithoutExtensionConf" > /etc/bind/zone/${domain}/${domainWithoutExtension}.conf;
        # Create db.${reverseIpLastDot}
        touch /etc/bind/zone/${domain}/db.${reverseIpLastDot};
        reverseIpLastDotDb=";
; BIND reverse data file for local loopback interface
;
\$TTL	604800
@	IN	SOA	${domain}. root.${domain}. (
                1		; Serial
            604800		; Refresh
            86400		; Retry
            2419200		; Expire
            604800 )	; Negative Cache TTL
;
@	IN	NS	${domain}.
200	IN	PTR	${domain}. 
";
        echo "$reverseIpLastDotDb" > /etc/bind/zone/${domain}/db.${reverseIpLastDot};
        # Create db.${domainWithoutExtension}
        touch /etc/bind/zone/${domain}/db.${domainWithoutExtension};
        dbDotDomainWithoutExtension=";
; BIND data file for local loopback interface
;
\$TTL	604800
@	IN	SOA	${domain}. root.${domain}. (
                2		; Serial
            604800		; Refresh
            86400		; Retry
            2419200		; Expire
            604800 )	; Negative Cache TTL
;
@	IN	NS	${domain}.
@	IN	A	${ip}
@	IN	PTR	${domain}.
";
        echo "$dbDotDomainWithoutExtension" > /etc/bind/zone/${domain}/db.${domainWithoutExtension};
        # Restart bind9
        printf "${Blue} 🚀 Restarting Bind9 ... ${NC} \n";
        systemctl restart bind9 > /dev/null 2>&1;
        rndc reload > /dev/null 2>&1;
        printf "${Green} 🎉 Bind9 is restarted ${NC} \n";
        # check domain is bind or not
        printf "${Blue} 🚀 Checking domain is bind or not ... ${NC} \n";
        # Check if dig is installed
        dpkg -s dnsutils > /dev/null 2>&1 || {
            printf "${Blue} 🚀 Installing dig ... ${NC} \n";
            apt-get install -y dnsutils > /dev/null 2>&1;
            printf "${Green} 🎉 dig is installed ${NC} \n";
        }
        #Get First ip of domain with dig
        digIp=$(dig +short $domain | head -1)
        if [ "$ip" = "$digIp" ]; then
            printf "${Green} 🎉 Domain is binded successfully ${NC} \n";
        else
            printf "${Red} ❌ Domain is not binded ${NC} \n";
            exit 1;
        fi
        # wait 5 secound
        sleep 5;
        main;
}

#Remove a domain
RemoveDomain() {
    read -p "Enter the domain name: " domain
    # Check if domain is binded
    printf "${Blue} 🚀 Checking domain is binded or not ... ${NC} \n";
    # Check if dig is installed
    dpkg -s dnsutils > /dev/null 2>&1 || {
        printf "${Blue} 🚀 Installing dig ... ${NC} \n";
        apt-get install -y dnsutils > /dev/null 2>&1 & spinner;
        printf "${Green} 🎉 dig is installed ${NC} \n";
    }
    # Get Ip
    ip=$(ip -4 addr | sed -ne 's|^.* inet \([^/]*\)/.* scope global.*$|\1|p' | head -1);
    #Get First ip of domain with dig
    digIp=$(dig +short $domain | head -1)
    if [ "$ip" = "$digIp" ]; then
        printf "${Green} 🎉 Domain is not binded ${NC} \n";
    else
        domainWithoutExtension=$(echo $domain | cut -d '.' -f1);
        # empty file /etc/bind/named.conf.local
        echo > /etc/bind/named.conf.local
        # empty file /etc/bind/named.conf.local.save
        echo > /etc/bind/named.conf.local.save
        # empty file /etc/bind/zone/${domain}/db.${domainWithoutExtension}
        rm -r /etc/bind/zone/${domain}
        # Restart bind9
        printf "${Blue} 🚀 Restarting Bind9 ... ${NC} \n";
        systemctl restart bind9 > /dev/null 2>&1 & spinner;
        rndc reload > /dev/null 2>&1 & spinner;
        printf "${Green} 🎉 Bind9 is restarted ${NC} \n";
        # check domain is bind or not
        printf "${Blue} 🚀 Checking domain is bind or not ... ${NC} \n";
        #Get First ip of domain with dig
        digIp=$(dig +short $domain | head -1)
        if [ "$ip" = "$digIp" ]; then
            printf "${Green} 🎉 Domain is removed successfully ${NC} \n";
        else
            printf "${Red} ❌ Domain is not removed ${NC} \n";
            exit 1;
        fi
        # wait 5 secound
        sleep 5;
        main;
    fi
}

spinner() {
    local pid=$!
    local delay=0.75
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

#Get SSL
getSSL() {
    read -p "Enter the domain name: " domain
    # Check if certbot is installed
    if ! command -v certbot &> /dev/null; then
        printf "${Blue} 🚀 Installing certbot ... ${NC} \n";
        # Check snap is installed
        dpkg -s snapd > /dev/null 2>&1 || {
            printf "${Blue} 🚀 Installing snap ... ${NC} \n";
            apt-get install -y snapd > /dev/null 2>&1;
            printf "${Green} 🎉 snap is installed ${NC} \n";
        }
        snap install --classic certbot > /dev/null 2>&1;
        ln -s /snap/bin/certbot /usr/bin/certbot > /dev/null 2>&1;
        printf "${Green} 🎉 certbot is installed ${NC} \n";
    fi
    # Check if ufw is installed then port 80 and 443 is open
    if command -v ufw &> /dev/null; then
        ufw allow 80 > /dev/null 2>&1;
        ufw allow 443 > /dev/null 2>&1;
    fi
    printf "${Blue} 🚀 Starting get SSL ... ${NC} \n";
    # Check port 80 is not used and open
    # Check if lsof is not installed then install
    dpkg -s lsof > /dev/null 2>&1 || {
        printf "${Blue} 🚀 Installing lsof ... ${NC} \n";
        apt-get install -y lsof > /dev/null 2>&1;
        printf "${Green} 🎉 lsof is installed ${NC} \n";
    }
    # if port 80 is used then exit
    if lsof -i :80 > /dev/null 2>&1; then
        # Get the name of process using port 80
        process=$(lsof -i :80 | awk '{print $1}' | tail -n 1)
        printf "${Red} ❌ Port 80 is already in use by $process ${NC} \n";
        exit 1;
    fi
    # Get SSL Certificate
    certbot certonly --standalone --non-interactive --agree-tos --register-unsafely-without-email -d $domain > /dev/null 2>&1 & spinner;
    # Check if certificates are created
    if [ -f /etc/letsencrypt/live/$domain/fullchain.pem ]; then
        printf "${Green} 🎉 Certificates are created successfully ${NC} \n";
        printf "${Green} 💁 Your certificate information is: ${NC} \n";
        certbot certificates -d $domain
        # wait 5 secound
        sleep 5;
        main;
    else
        printf "${Red} ❌ Certificates are not created ${NC} \n";
        exit 1;
    fi
}

# Install Docker
installDocker() {
    # Check if docker is installed or not
    if command -v docker &> /dev/null; then
        printf "${Green} ✅ Docker is already installed ${NC} \n";
        printf "${Green} 💁 Your Docker information is: ${NC} \n";
        docker info;
    else
    printf "${Blue} 🚀 Starting Install Docker ... ${NC} \n";
    bash -c "$(curl -sSL https://get.docker.com)" > /dev/null 2>&1 & spinner;
    printf "${Green} 🎉 Install Docker is complete ${NC} \n";
    printf "${Green} 💁 Your Docker information is: ${NC} \n";
    docker info;
    fi
    # wait 5 secound
    sleep 5;
    main;
}

# Show current hostname
showHostname() {
    hostnamectl --static;
}

# Change Hostname
changeHostname() {
    read -p "Enter the new hostname: " hostname
    hostnamectl set-hostname $hostname
    printf "${Green} 🎉 Hostname is changed ${NC} \n";
    printf "${Green} 💁 Your Hostname information is: ${NC} \n";
    hostnamectl
    # wait 5 secound
    sleep 5;
    main;
}

# Main
main() {
    clear
    displayLogo

    printf "${Yellow}Welcome to MahiMana script - a server tool!${NC}\n"
    printf "${Yellow}-------------------------------------------${NC}\n"
    printf "${Yellow}Choose an option:${NC}\n"
    printf "${Cyan}1. Update and upgrade the system${NC}\n"
    printf "${Cyan}2. Change SSH port ${Purple}($(FindSSHPort)) ${Red}[Server]${NC}\n"
    printf "${Cyan}3. Bind a domain ${Blue}(bind9) ${Red}[Server]${NC}\n"
    printf "${Cyan}4. Remove a domain ${Blue}(bind9) ${Red}[Server]${NC}\n"
    printf "${Cyan}5. Get single SSL certificate for a domain ${Red}[Server]${NC}\n"
    printf "${Cyan}6. Install Docker${NC}\n"
    printf "${Cyan}7. Change Hostname ${Purple} ($(showHostname)) ${Red}[Server]${NC}\n"

    read -p "Enter your choice: " choice

    case $choice in
        1)
            updateAndUpgrade
            ;;
        2)
            changeSSHPort
            ;;
        3)
            BindDomain
            ;;
        4)
            RemoveDomain
            ;;
        5)
            getSSL
            ;;
        6)
            installDocker
            ;;
        7)
            changeHostname
            ;;
        *)
            printf "${Red}Invalid choice. Exiting.${NC}\n"
            exit 1
            ;;
    esac
}

#Execute the main function
main