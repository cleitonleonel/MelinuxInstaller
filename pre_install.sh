#!/bin/bash
# Shell installing Melinux prerequites
# Otmasolucoes version 2022
# For Melinux contribs and components

sudo rm /var/lib/apt/lists/lock
sudo rm /var/lib/dpkg/lock
sudo rm /var/lib/dpkg/lock-frontend
sudo rm /var/cache/apt/archives/lock
sudo dpkg --configure -a

# Iniciando instalação
sudo apt update -y
sudo apt list --upgradable
sudo apt upgrade
sudo apt autoremove -y

echo 'Instalando libs extra'
sudo apt install libhdf5-dev -y
sudo apt install libpq-dev -y
sudo apt install libssl-dev zlib1g-dev gcc g++ make -y

echo ${USER}

# Check Sistema Operacional
ARCH=$(uname -m)

if [ "$OSTYPE" == "linux-gnu" -a "${ARCH}" == "x86_64" ];
  then
    OS='Linux-x86_64'
elif [[ "$OSTYPE" == "linux-android"* ]];
  then
    OS='Android'
elif [[ "$OSTYPE" == "darwin"* ]];
  then
    OS='Mac OSX'
elif [[ "$OSTYPE" == "cygwin" ]];
  then
    OS='Windows'
elif [[ "$OSTYPE" == "msys" ]];
  then
    OS='Windows'
elif [[ "$OSTYPE" == "win32" ]];
  then
    OS='Windows-32'
elif [[ "$OSTYPE" == "freebsd"* ]];
  then
    OS='Linux-Freebsd'
elif [ "$OSTYPE" == "linux-gnu" -a "${ARCH}" == "aarch64" ];
  then
    OS='Raspberry'
else
    OS='Unknown'
fi

echo 'Seu sistema operacional é ' ${OS}


# Definindo o path do projeto
echo 'Path do projeto'
project_system='melinux_web'

if [[ "${OS}" == "Linux-x86_64" ]];
  then
    sudo mkdir /home/${USER}/${project_system}
    sudo chmod 777 -R /home/${USER}/${project_system}
    sudo chown ${USER}:${USER} -R /home/${USER}/${project_system}
elif [[ "${OS}" == "Raspberry" ]];
  then
    sudo mkdir /home/${USER}/${project_system}
    sudo chmod 777 -R /home/${USER}/${project_system}
    sudo chown ${USER}:${USER} -R /home/${USER}/${project_system}
fi


# Check and installing git
if which git > /dev/null 2>&1;
then
    echo 'Git já está instalado.'
else
    echo 'Instalando git...'
    sudo apt install git -y
fi

# Check and installing npm
if which npm > /dev/null 2>&1;
then
    echo 'npm já está instalado.'
else
    echo 'Instalando npm...'
    sudo apt install npm -y
fi

# Check and installing Bower
if which bower > /dev/null 2>&1;
then
    echo 'Bower já está instalado.'
else
    echo 'Instalando bower...'
    sudo npm install -g bower -y
fi

# Check and installing Postrgresql
if which psql > /dev/null 2>&1;
then
    echo 'Postgresql já está instalado.'
else
    echo 'Instalando Postrgresql...'
    sudo apt install postgresql postgresql-contrib -y
fi

# Criando usuário Postgrsql
echo 'Criando senha para o usuário 'postgres'...'
sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

echo 'Criando database...'
sudo -u postgres createdb 'test_project'

# Check and installing Python3
if which python3.8 > /dev/null 2>&1;
then
    echo 'Python3.8 já está instalado.'
else
    echo 'Instalando Python3.8...'
    sudo apt install python3.8 -y
fi

# Check and installing pip
if which pip3 > /dev/null 2>&1;
then
    echo 'Pip3 já está instalado.'
else
    echo 'Instalando Pip3...'
    sudo apt install python3-pip -y
fi

# Corrigir possíveis erros na instalação de dependências do python3
echo 'Instalando uma correção de libs python3...'
sudo apt install python3-dev -y
sudo apt install python3-wheel -y
sudo apt install python3-setuptools -y
sudo apt install python3.8-venv python3-venv -y
sudo apt-get install python3-distutils
sudo apt autoremove -y

declare -a array=()
i=0

while IFS= read -r line; do
    array[i]=$line
    let "i++"
done < /home/${USER}/MelinuxInstaller/config/profile.py

user=$(echo ${array[0]} | sed "s/GITHUB_USER = '/'/g")

pass=$(echo ${array[1]} | sed "s/GITHUB_PASSWORD = '/'/g")

token=$(echo ${array[2]} | sed "s/GITHUB_TOKEN = '/'/g")

user=$(echo ${user} | sed "s/'//g")
pass=$(echo ${pass} | sed "s/'//g")
token=$(echo ${token} | sed "s/'//g")


if [[ "${user}" == "" ]];
  then
    echo 'Antes de executar esse arquivo configure o arquivo profile.py em' /home/${USER}/MelinuxInstaller/config/
    exit 0
fi

# Download do projeto
echo 'Instalando o projeto...'
echo ${token}
git clone https://${token}@github.com/otmasolucoes/test_project.git /home/${USER}/${project_system}

# Movendo arquivos
echo 'Configurando as pastas do projeto.'
sudo mv ./profile.py /home/${USER}/${project_system}/conf/profile.py
# Mudando de diretório e movendo os arquivos
sudo mv * /home/${USER}/${project_system}
sudo rm -r /home/${USER}/MelinuxInstaller
sudo chmod 777 -R /home/${USER}/${project_system}
cd /home/${USER}/${project_system} || return

# Create virtualenv
echo 'Criando ambiente virtual do projeto'
# python3 -m pip install virtualenv --no-warn-script-location
python3 -m venv /home/${USER}/venv_melinux
sudo chmod 777 -R /home/${USER}/venv_melinux
env=/home/${USER}/venv_melinux/bin/activate
echo 'Ativando ambiente virtual'
source ${env}

#echo 'Desativando ambiente virtual'
#deactivate

# Dependências do projeto
echo 'Instalando o requirements do projeto...'
py=/home/${USER}/venv_melinux/bin/python3
pip_install="pip3 install"
pip_uninstall="pip3 uninstall"
manager="install_project.py install"
${pip_install} --upgrade pip wheel setuptools
${py} ${manager}

# Instalando dependências do frontend
echo "Bower install, dependências frontend..."
bower_install="manage.py bower_install --allow-root"
${py} ${bower_install}

# Subindo as migrações para o banco de dados.
echo 'Populando o banco de dados...'
db_clean="manage.py db_clean authentication entities communications security commons products commands"
${py} ${db_clean}

source ${env}

#run="manage.py runserver"
#${py} ${run}

# Fechando script
echo 'Saindo...'
exit 0