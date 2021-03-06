#!/bin/bash
# Shell installing Melinux prerequites
# Otmasolucoes version 2020
# For Melinux contribs and components

# Iniciando instalação
sudo apt update & sudo apt upgrade -y

echo 'Instalando libs extra'
sudo apt install libhdf5-dev
sudo apt install -y libpq-dev
sudo apt install -y libssl-dev zlib1g-dev gcc g++ make

sudo chown -R $USER:$USER ./
sudo mkdir ../arm_melinux

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
    sudo npm install -g bower
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
if which python3 > /dev/null 2>&1;
then
    echo 'Python3 já está instalado.'
else
    echo 'Instalando Python3...'
    sudo apt install python3 -y
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

# Definindo o path do projeto

echo 'Path do projeto'
if [[ "${OS}" == "Linux-x86_64" ]];
  then
    project_system='lin_melinux'
elif [[ "${OS}" == "Raspberry" ]];
  then
    project_system='arm_melinux'
fi

declare -a array=()
i=0

while IFS= read -r line; do
    array[i]=$line
    let "i++"
done < "/home/MelinuxInstaller/config/profile.py"

user=$(echo ${array[0]} | sed "s/GITHUB_USER = '/'/g")

pass=$(echo ${array[1]} | sed "s/GITHUB_PASSWORD = '/'/g")

user=$(echo ${user} | sed "s/'//g")
pass=$(echo ${pass} | sed "s/'//g")

if [[ "${user}" == "" ]];
  then
    echo 'Antes de executar esse arquivo configure o arquivo profile.py em' /home/$USER/MelinuxInstaller/config/
    exit 0
fi

# Mudando de diretório e movendo os arquivos
sudo mv * ../arm_melinux
dir=../arm_melinux
cd ${dir}

# Create virtualenv
echo 'Criando ambiente virtual do projeto'
# python3 -m pip install virtualenv --no-warn-script-location
sudo apt install python3-virtualenv -y
virtualenv venv_melinux
env='venv_melinux/bin/activate'
echo 'Ativando ambiente virtual'
source ${env}

#echo 'Desativando ambiente virtual'
#deactivate

# Dependências do projeto
echo 'Instalando o requirements do projeto...'
py="/home/${project_system}/venv_melinux/bin/python"
pip_install="pip install"
pip_uninstall="pip uninstall"
manager="install_project.py install"
${pip_install} -U setuptools
${py} ${manager}

# Download do projeto
echo 'Instalando o projeto...'

username=${user}
password=${pass}

echo ${username}
echo ${password}

git clone https://${username}:${password}@github.com/otmasolucoes/test_project.git ./temp

# Movendo arquivos
echo 'Configurando as pastas do projeto.'
sudo mv ./temp/* ./
sudo rm -r ./temp
sudo mv ./profile.py ./conf/profile.py

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