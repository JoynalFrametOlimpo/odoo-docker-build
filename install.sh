# Config and Install Odoo Server
# Author: Joynal Framet Olimpo - 2020

ODOO_PATH="./odoo-develop"
ODOO_VERSION="13.0"

# Date Config
if [ -f /etc/localtime/ ]; then
  cp /usr/share/zoneinfo/America/Guayaquil /etc/localtime 
fi

dt=$(date '+%d-%m-%Y--%H-%M-%S')

# For backup environment directory
if [ ! -d ./backup-environment ]; then
    mkdir ./backup-environment
fi

# Security Backup
if [ -d ./odoo-develop ]; then
     mv ./odoo-develop "./backup-environment/odoo-develop.$dt"
     rm -rf "$ODOO_PATH"
fi

# Install docker - docker-compose
. /etc/os-release
SO=$ID

# Install docker and docker-compose Centos
if [ "$SO" = "centos" ]; then
     echo "$(tput setaf 4)***************** UPGRADE SO ************************************************$(tput setaf 3)"
     yum -y upgrade
     echo "(tput setaf 4)***************** UPDATE SO ************************************************$(tput setaf 3)"
     yum -y update
     echo "(tput setaf 4)***************** INSTALLING DEPENDS ***************************************$(tput setaf 3)"
     yum install -y yum-utils device-mapper-persistent-data lvm2 --no-install-recommends
     yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
     echo "(tput setaf 4)***************** INSTALL DOCKER ******************************************$(tput setaf 3)"
     yum install -y docker-ce
     usermod -aG docker $(whoami)
     gpasswd -a ${USER} docker
     systemctl enable docker.service
     systemctl start docker.service
     yum install -y epel-release
     echo "(tput setaf 4)*************** INSTALL Python-pip ****************************************$(tput setaf 3)"
     yum install -y python-pip --no-install-recommends
     echo "(tput setaf 4)************** INSTALL DOCKER-COMPOSE *************************************$(tput setaf 3)"
     pip install docker-compose --no-install-recommends
     echo "(tput setaf 4)************* Upgrade Python *********************************************$(tput setaf 3)"
     yum -y upgrade python --no-install-recommends
     docker version
     docker-compose version
fi

if [ "$SO" = "ubuntu" ]; then
     echo "$(tput setaf 4)***************** UPGRADE SO ************************************************$(tput setaf 3)"
     apt-get upgrade -y
     echo "$(tput setaf 4)***************** UPDATE SO ************************************************$(tput setaf 3)"
     apt-get update -y
     echo "$(tput setaf 4)***************** INSTALL DOCKER ******************************************$(tput setaf 3)"
     apt-get -y install docker.io --no-install-recommends
     echo "$(tput setaf 4)***************** INSTALL DOCKER-COMPOSE******************************************$(tput setaf 3)"
     apt-get -y install docker-compose --no-install-recommends
     echo "$(tput setaf 4)***************** INFORMATION DOCKER******************************************$(tput setaf 3)"
     groupadd docker
     usermod -aG docker $USER
     docker version
     docker-compose version
fi

if [ ! -d "$ODOO_PATH/13" ]; then
    mkdir -p "$ODOO_PATH/13"
fi

# Build Image Odoo-base without source
echo "$(tput setaf 4)***************** Construyendo imagen odoo base sin fuente *********************$(tput setaf 3)"
make build-base

# Donwload odoo git
echo "$(tput setaf 4)***************** Clonando proyecto de Odoo de la comunidad de Odoo en Github *********************$(tput setaf 3)"
mkdir "$ODOO_PATH/13/src/" && git clone --depth 1 https://github.com/odoo/odoo.git "$ODOO_PATH/13/src/" 
chmod -R 777 "$ODOO_PATH/13/"

# Build Odoo-Base Image 
echo "$(tput setaf 4)***************** Construyendo imagen odoo:13.0 *********************$(tput setaf 3)"
make build

# Copy odoo configuration file in new project
if [ ! -f "$ODOO_PATH/13/conf/odoo.conf" ]; then
    echo "$(tput setaf 4)***************** Copiando archivo odoo.conf en ruta de proyecto*********************$(tput setaf 3)"
    mkdir "$ODOO_PATH/13/conf/" &&  cp ./odoo.conf "$ODOO_PATH/13/conf/"
fi

chmod +x ./entrypoint.sh ./wait-for-psql.py
chmod -R 777 "$ODOO_PATH/13/"

echo "$(tput setaf 1)****************** Levantando Servicios *******************************$(tput setaf 3)"
make compose

chmod -R 777 "$ODOO_PATH/13/"
make logs



