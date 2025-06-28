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

# Install Nginx
installNginx() {
    # Check if nginx is installed or not
    if command -v nginx &> /dev/null; then
        printf "${Green} ✅ Nginx is already installed ${NC} \n";
    else
    printf "${Blue} 🚀 Starting Install Nginx ... ${NC} \n";
    apt-get install -y nginx > /dev/null 2>&1 & spinner;
    printf "${Green} 🎉 Install Nginx is complete ${NC} \n";
    fi
    # Start and enable nginx
    systemctl start nginx > /dev/null 2>&1 & spinner;
    systemctl enable nginx > /dev/null 2>&1 & spinner;
    printf "${Green} 🎉 Nginx is running ${NC} \n";
    printf "${Green} 💁 Your Nginx information is: ${NC} \n";
    nginx -v
    # wait 5 secound
    sleep 5;
    main;
}

# Get SSL for domain with Nginx
getSSLWithNginx() {
    # Check if Nginx is installed
    if ! command -v nginx &> /dev/null; then
        # Install nginx
        printf "${Blue} 🚀 Installing Nginx ... ${NC} \n";
        apt-get install -y nginx > /dev/null 2>&1 & spinner;
        printf "${Green} 🎉 Nginx is installed ${NC} \n";
    fi
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
    # Get domain
    read -p "Enter the domain: " domain
    # Get SSL
    certbot --nginx --non-interactive --agree-tos --register-unsafely-without-email -d $domain > /dev/null 2>&1 & spinner;
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

# Install NVM
installNVM() {
    printf "${Blue} 🚀 Starting install NVM ... ${NC} \n";
    # Check if nvm is installed
    if command -v nvm &> /dev/null; then
        printf "${Green} ✅ NVM is already installed ${NC} \n";
        printf "${Green} 💁 Your NVM information is: ${NC} \n";
        nvm --version;
        
        # wait 5 secound
        sleep 5;
        main;
    fi

    # Check if curl is not installed
    if ! command -v curl &> /dev/null; then
        # Install curl
        printf "${Blue} 🚀 Installing curl ... ${NC} \n";
        apt-get install -y curl > /dev/null 2>&1 & spinner;
        printf "${Green} 🎉 curl is installed ${NC} \n";
    fi
    bash <(curl -sL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh) > /dev/null 2>&1 & spinner;
    printf "${Green} 🎉 NVM is installed ${NC} \n";
    # Ask for reopen shell
    read -p "Do you want to reopen shell? (y/n): " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        # Reopen shell
        exec $SHELL
    fi

    # Show nvm version
    printf "${Blue} 💁 Your nvm version is: ${NC} \n";
    nvm --version; 
    # wait 5 secound
    sleep 5;
    main;
}

# Add SSH key
addSSHKey() {
    printf "${Blue} 🚀 Starting add SSH key ... ${NC} \n";
    # Check if .ssh folder not exists
    if [ ! -d /root/.ssh ]; then
        mkdir /root/.ssh
    fi
    # Check if authorized_keys file not exists
    if [ ! -f /root/.ssh/authorized_keys ]; then
        touch /root/.ssh/authorized_keys
    fi
    # Show info about how to create SSH key
    printf "${Green} 💁 How to create SSH key ${NC} \n";
    printf "${Green} Run: ssh-keygen -t rsa ${NC} \n";
    printf "${Green} Run: cat ~/.ssh/id_rsa.pub ${NC} \n";

    # Add SSH key
    read -p "Enter your SSH key: " -r ssh_key
    echo "$ssh_key" >> /root/.ssh/authorized_keys
    printf "${Green} 🎉 SSH key is added ${NC} \n";

    # Sleep 5 secound
    sleep 5;
    main;
}

# Show Open ports
showOpenPorts() {
    if command -v ufw &> /dev/null; then
        message=$(ufw status | grep -q "Status: active" && echo "ufw is enabled" || echo "ufw is disabled");
        # Check if message is "ufw is enabled" then show open ports
        if [ "$message" == "ufw is enabled" ]; then
        # Get all open ports and concat together with - ==> | tr '\n' '-' | sed 's/-$//'
            openPorts=$(ufw status | grep "ALLOW" | awk '{print $1}')
            printf "${Purple}Open ports:\n$openPorts\n ${NC}";
        else
            echo "$message";
        fi
    else
        echo "ufw is not installed"
    fi
    # Ask for back to main
    read -p "Do you want to back to main menu? (y/n): " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        main
    fi
}

# Check Firewall
CheckFirewall() {
    if command -v ufw &> /dev/null; then
        message=$(ufw status | grep -q "Status: active" && echo "ufw is enabled" || echo "ufw is disabled");
        echo "$message";
    else
        echo "ufw is not installed"
    fi
}

# Change Firewall status
ChangeFirewallStatus() {
    if command -v ufw &> /dev/null; then
        # Check if ufw is disabled the enable it and if it is enabled then disable it
        if ufw status | grep "Status: inactive" > /dev/null 2>&1; then
            read -p "Enter the ports that you want to open: (separated by comma)" port;
            printf "${Blue} 🚀 Starting Firewall and opening ports ... ${NC} \n";
            for p in $(echo $port | sed "s/,/ /g"); do
                ufw allow $p > /dev/null 2>&1;
            done
            ufw enable > /dev/null 2>&1 & spinner;
            printf "${Green} 🎉 Firewall is started ${NC} \n";
        else
            printf "${Blue} 🚀 Stopping Firewall ... ${NC} \n";
            ufw disable > /dev/null 2>&1 & spinner;
            printf "${Green} 🎉 Firewall is stopped ${NC} \n";
        fi
    else
        echo "ufw is not installed";
    fi
    # Sleep 5sec
    sleep 5;
    main;
}

# Open new port
openNewPort() {
    read -p "Enter the new port: " new_port
    printf "${Blue} 🚀 Opening port ... ${NC} \n";
    ufw allow $new_port > /dev/null 2>&1 & spinner;
    printf "${Green} 🎉 Firewall is opened sucessfully ${NC} \n";
    sleep 5;
    main;
}

# Close port
closePort() {
    read -p "Enter the port: " port
    printf "${Blue} 🚀 Closing port ... ${NC} \n";
    ufw deny $port > /dev/null 2>&1 & spinner;
    printf "${Green} 🎉 Firewall is closed sucessfully ${NC} \n";
    sleep 5;
    main;
}

# Add user
addUser() {
    read -p "Enter the username: " username
    stty -echo
    read -p "Enter the password: " password
    stty echo
    printf "\n${Blue} 🚀 Adding user ... ${NC} \n";
    adduser --disabled-password --gecos "" $username > /dev/null 2>&1 & spinner;
    echo "$username:$password" | chpasswd > /dev/null 2>&1 & spinner;
    # Ask to be admin
    read -p "Are $username is admin? (y/n): " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        usermod -aG sudo $username
    fi
    printf "${Green} 🎉 User is added sucessfully ${NC} \n";
    sleep 5;
    main;
}

changePassword() {
    read -p "Enter the username: " username
    # Check if user exists
    if ! id -u $username > /dev/null 2>&1; then
        printf "${RED}❌ User $username does not exist ${NC}\n";
        sleep 5;
        main;
    fi
    stty -echo
    read -p "Enter the password: " password
    stty echo
    printf "\n${Blue} 🚀 Changing password ... ${NC} \n";
    echo "$username:$password" | chpasswd > /dev/null 2>&1 & spinner;
    printf "${Green} 🎉 Password is changed sucessfully ${NC} \n";
    sleep 5;
    main;
}

# Delete User
deleteUser() {
    read -p "Enter the username: " username
    printf "${Blue} 🚀 Deleting user ... ${NC} \n";
    userdel -r $username > /dev/null 2>&1 & spinner;
    printf "${Green} 🎉 User is deleted sucessfully ${NC} \n";
    sleep 5;
    main;
}

# Install x-ui
installXUI() {
    printf "${Blue} 🚀 Starting install x-ui ... ${NC} \n";
    bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh)
    printf "${Green} 🎉 x-ui is installed ${NC} \n";
    sleep 5;
    main;
}

InstallHiddify() {
    printf "${Blue} 🚀 Starting install Hiddify ... ${NC} \n";
    bash <(curl i.hiddify.com/release)
    printf "${Green} 🎉 Hiddify is installed ${NC} \n";
    sleep 5;
    main;
}

InstallMarzban() {
    printf "${Blue} 🚀 Starting install Marzban ... ${NC} \n";
    bash -c "$(curl -sL https://github.com/Gozargah/Marzban-scripts/raw/master/marzban.sh)" @ install
    printf "${Green} 🎉 Marzban is installed ${NC} \n";
    sleep 5;
    main;
}

TorSina() {
    bash <(curl -Ls https://raw.githubusercontent.com/sinasims/torsina/refs/heads/main/install.sh)
}

# Install Dokploy
dokploy() {
    curl -sSL https://dokploy.com/install.sh | sh
}

# Install needed tools ( ufw, nano, lynis, fail2ban )
neededToolsAndSecurity() {
    printf "${Blue} 🚀 Starting install needed tools and security ... ${NC} \n";
    apt-get update > /dev/null 2>&1 & spinner;
    apt-get upgrade -y > /dev/null 2>&1 & spinner;
    apt-get install -y ufw nano lynis fail2ban > /dev/null 2>&1 & spinner;
    printf "${Green} 🎉 Needed tools and security is installed ${NC} \n";
    sleep 5;
    main
}

coolify() {
    curl -fsSL https://cdn.coollabs.io/coolify/install.sh | bash
}

installTXUI() {
  printf "${Blue} 🚀 Starting install TX-UI ... ${NC} \n";
  bash <(curl -Ls https://raw.githubusercontent.com/AghayeCoder/tx-ui/master/install.sh);
  printf "${Green} 🎉 TX-UI is installed ${NC} \n";
  sleep 5;
  main;
}

ChangeMOTD() {
    printf "${Blue} 🚀 Changing MOTD ... ${NC} \n"

    local path="/etc/update-motd.d/00-awesome-motd"

    # حذف نسخه قبلی
    [ -f "$path" ] && sudo rm -f "$path"

    # نصب ابزارهای لازم
    command -v neofetch >/dev/null 2>&1 || {
        echo -e "${DIM}Installing neofetch...${RESET}"
        apt-get update -qq && apt-get install -y neofetch >/dev/null 2>&1
    }

    command -v geoiplookup >/dev/null 2>&1 || {
        echo -e "${DIM}Installing geoiplookup...${RESET}"
        apt-get install -y geoip-bin >/dev/null 2>&1
    }

    # نوشتن MOTD
    tee "$path" > /dev/null <<'EOF'
#!/usr/bin/env bash

RESET="\e[0m"; BOLD="\e[1m"; DIM="\e[2m"
GREEN="\e[38;5;82m"; YELLOW="\e[38;5;220m"; RED="\e[38;5;196m"
CYAN="\e[38;5;51m"; MAGENTA="\e[38;5;213m"

HOST=$(hostname)
KERNEL=$(uname -r)
OS=$(grep "^PRETTY_NAME=" /etc/os-release | cut -d= -f2 | tr -d '"')
UPTIME=$(uptime -p | sed 's/up //')
LOAD=$(cut -d " " -f1-3 /proc/loadavg)
IP_LOCAL=$(hostname -I | awk '{print $1}')
MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
DISK_USED=$(df -m / | awk 'NR==2 {print $3}')
DISK_TOTAL=$(df -m / | awk 'NR==2 {print $2}')
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
USERS=$(who | wc -l)
USER=$(whoami)
USER_ID=$(id -u)

# گرفتن آی‌پی عمومی واقعی
IP_PUBLIC=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}' | head -n1)

# تشخیص کشور با geoiplookup
if [[ -n "$IP_PUBLIC" ]]; then
  COUNTRY_LINE=$(geoiplookup "$IP_PUBLIC")
  COUNTRY_NAME=$(echo "$COUNTRY_LINE" | cut -d: -f2 | sed 's/^ //')
  COUNTRY_CODE=$(echo "$COUNTRY_LINE" | grep -oP '\((\K[A-Z]+)')
else
  COUNTRY_NAME="Unknown"
  COUNTRY_CODE="--"
fi

# ساخت پرچم ایموجی
flag_emoji() {
  code=$(echo "$1" | tr '[:lower:]' '[:upper:]')
  for (( i=0; i<${#code}; i++ )); do
    char=${code:i:1}
    printf "\U$(printf '%x' $((0x1F1E6 + $(printf '%d' "'$char") - 65)))"
  done
}
FLAG=$(flag_emoji "$COUNTRY_CODE")

progress_bar() {
  local used=$1
  local total=$2
  local width=24
  local ratio fill empty percent COLOR bar

  ratio=$(awk -v u="$used" -v t="$total" 'BEGIN { if (t > 0) printf "%.2f", u / t; else print 0 }')
  fill=$(awk -v r="$ratio" -v w="$width" 'BEGIN { printf "%d", r * w }')
  empty=$((width - fill))

  if (( $(echo "$ratio < 0.5" | bc -l) )); then
    COLOR=$GREEN
  elif (( $(echo "$ratio < 0.8" | bc -l) )); then
    COLOR=$YELLOW
  else
    COLOR=$RED
  fi

  bar="${COLOR}"
  for ((i = 0; i < fill; i++)); do bar+="█"; done
  bar+="${DIM}"
  for ((i = 0; i < empty; i++)); do bar+="░"; done
  bar+="${RESET}"
  percent=$(awk -v r="$ratio" 'BEGIN { printf "%.0f", r * 100 }')

  printf "%s  %s%%" "$bar" "$percent"
}

clear
neofetch --ascii_distro auto --color_blocks off --disable packages
echo ""
echo -e "${BOLD}${MAGENTA}🎉 Welcome to $COUNTRY_NAME server! 🎉${RESET}"
echo ""

echo -e "${CYAN}┏━ ${BOLD}System${RESET}"
echo -e "${CYAN}┃${RESET} 🖥️  Hostname   : $HOST"
echo -e "${CYAN}┃${RESET} 🐧 OS         : $OS"
echo -e "${CYAN}┃${RESET} 🧠 Kernel     : $KERNEL"
echo -e "${CYAN}┃${RESET} ⏱️  Uptime     : $UPTIME"
echo -e "${CYAN}┃${RESET} 📊 Load Avg   : $LOAD"
echo -e "${CYAN}┃${RESET} 👥 Users      : $USERS"
echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

echo -e "${CYAN}┏━ ${BOLD}Resources${RESET}"
echo -e "${CYAN}┃${RESET} 💾 Memory     : $(progress_bar $MEM_USED $MEM_TOTAL)  ${MEM_USED}MiB / ${MEM_TOTAL}MiB"
echo -e "${CYAN}┃"
echo -e "${CYAN}┃${RESET} 🗄️  Disk       : $(progress_bar $DISK_USED $DISK_TOTAL)  ${DISK_USED}MiB / ${DISK_TOTAL}MiB"
echo -e "${CYAN}┃"
echo -e "${CYAN}┃${RESET} ⚙️  CPU Usage  : $(progress_bar $CPU_USAGE 100)  $(printf "%.0f%%" $CPU_USAGE)"
echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

echo -e "${CYAN}┏━ ${BOLD}Network${RESET}"
echo -e "${CYAN}┃${RESET} 🌐 Local IP   : $IP_LOCAL"
echo -e "${CYAN}┃${RESET} 🌍 Public IP  : $IP_PUBLIC  ($FLAG $COUNTRY_NAME)"
echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

echo -e "${CYAN}┏━ ${BOLD}User Info${RESET}"
echo -e "${CYAN}┃${RESET} 🧑 User       : $USER (UID $USER_ID)"
echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${DIM}MOTD generated with ❤️  by you. ${RESET}"
EOF

    # اعمال مجوز اجرا
    echo "🧰 Setting permissions..."
    sudo chmod +x "$path"
    sudo chmod -x /etc/update-motd.d/*
    sudo chmod +x "$path"
    printf "${Green} 🎉 MOTD is changed ${NC} \n"
    sleep 2
    main
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
    printf "${Cyan}8. Install Nginx ${Red}[Server]${NC}\n"
    printf "${Cyan}9. Get SSL for domain with Nginx ${Red}[Server]${NC}\n"
    printf "${Cyan}10. Install NVM (Node Version Manager)${NC}\n"
    printf "${Cyan}11. Add SSH Key ${Red}[Server]${NC}\n"
    printf "${Cyan}12. Active or deactive Firewall ${Purple}($(CheckFirewall))${NC}\n"
    printf "${Cyan}13. Show all Firewall open ports${NC}\n"
    printf "${Cyan}14. Open new port Firewall${NC}\n"
    printf "${Cyan}15. Close port Firewall${NC}\n"
    printf "${Cyan}16. Add new OS user${NC}\n"
    printf "${Cyan}17. Change Password for OS user${NC}\n"
    printf "${Cyan}18. Delete OS user${NC}\n"
    printf "${Cyan}19. Install x-ui${NC}\n"
    printf "${Cyan}20. Install Hiddify${NC}\n"
    printf "${Cyan}21. Install Marzban${NC}\n"
    printf "${Cyan}22. Install TorSina${NC}\n"
    printf "${Cyan}23. Install Dokploy${NC}\n"
    printf "${Cyan}24. Install needed tools and security (ufw, nano, lynis, fail2ban)${NC}\n"
    printf "${Cyan}25. Install Coolify${NC}\n"
    printf "${Cyan}26. Install TX-UI${NC}\n"
    printf "${Cyan}27. Change MOTD${NC}\n"

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
        8)
            installNginx
            ;;
        9)
            getSSLWithNginx
            ;;
        10)
            installNVM
            ;;
        11)
            addSSHKey
            ;;
        12)
            ChangeFirewallStatus
            ;;
        13)
            showOpenPorts
            ;;
        14)
            openNewPort
            ;;
        15)
            closePort
            ;;
        16)
            addUser
            ;;
        17)
            changePassword
            ;;
        18)
            deleteUser
            ;;
        19)
            installXUI
            ;;
        20)
            InstallHiddify
            ;;
        21)
            InstallMarzban
            ;;
        22)
            TorSina
            ;;
        23)
            dokploy
            ;;
        24)
            neededToolsAndSecurity
            ;;
        25)
            coolify
            ;;
        26)
            installTXUI
            ;;
        27)
            ChangeMOTD
            ;;
        *)
            printf "${Red}Invalid choice. Exiting.${NC}\n"
            exit 1
            ;;
    esac
}

#Execute the main function
main