#!/bin/bash
# Shell installing Melinux prerequites
# Otmasolucoes version 2022
# For Melinux contribs and components
#
COMMAND=$1

echo -e "\nInsira o token admin para iniciar a instalação do sistema\n"
read -rp 'Token: ' token

function exec_upgrades() {
  sudo apt --fix-broken install
  sudo rm /var/lib/apt/lists/lock
  sudo rm /var/lib/dpkg/lock
  sudo rm /var/lib/dpkg/lock-frontend
  sudo rm /var/cache/apt/archives/lock
  sudo dpkg --configure -a

  echo 'Instalando libs extra'
  sudo apt update -y
  sudo apt list --upgradable
  sudo apt upgrade
  sudo apt autoremove -y

  sudo apt install libhdf5-dev -y
  sudo apt install libpq-dev -y
  sudo apt install libssl-dev zlib1g-dev gcc g++ make -y
}

# Corrigir possíveis erros na instalação de dependências do python3
function exec_upgrades_python() {
  echo 'Instalando uma correção de libs python3...'
  sudo apt install python3-dev -y
  sudo apt install python3-wheel -y
  sudo apt install python3-setuptools -y
  sudo apt install python3.8-venv python3-venv -y
  sudo apt-get install python3-distutils
  sudo apt autoremove -y
}

if [ "$COMMAND" = "upgrade_all" ]
then
  exec_upgrades
  exec_upgrades_python
fi

echo "${USER}"

# Definindo o path do projeto
echo 'Path do projeto'
project_system='melinux_web'
mkdir ~/${project_system}
sudo chmod 777 -R ~/${project_system}

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

# Download do projeto
echo 'Instalando o projeto...'
echo "${token}"
git clone https://"${token}"@github.com/otmasolucoes/test_project.git ~/${project_system}

# Copiando arquivos
echo 'Configurando as pastas do projeto.'
mv ./profile.py ~/${project_system}/conf/profile.py
mv ./start_project.sh ~/${project_system}

chmod 777 -R ~/${project_system}

# Create virtualenv
echo 'Criando ambiente virtual do projeto'
mkdir ~/venvs
python3 -m venv ~/venvs/venv_melinux
chmod 777 -R ~/venvs/venv_melinux

cd ~/${project_system} || return
sed -i "10s/GITHUB_TOKEN = ''/GITHUB_TOKEN = '${token}'/" ./conf/profile.py

activate () {
  . ~/venvs/venv_melinux/bin/activate
}

echo 'Ativando ambiente virtual'
# rm -rf ~/MelinuxInstaller
# source ${env}
activate

# echo 'Desativando ambiente virtual'
# deactivate

# Dependências do projeto
echo 'Instalando o requirements do projeto...'
python -m pip install --upgrade pip wheel setuptools
python manager_pip.py install
python manager_pip.py uninstall
python manager_pip.py install

function force_install() {
  requirements='./conf/requirements/requirements.txt'
  dependencies='./conf/requirements/dependencies.txt'

  while read linha; do
  echo $py -m pip install "$linha"
  $py -m pip install "$linha"
  done < $requirements

  while read linha; do
  echo $py -m pip install git+https://"$token""$linha"
  $py -m pip install --no-cache-dir git+https://"$token""$linha"
  done < $dependencies
}

# Instalando dependências do frontend
echo "Bower install, dependências frontend..."
python manage.py bower_install --allow-root

# Subindo as migrações para o banco de dados.
echo 'Populando o banco de dados...'
python manage.py db_clean authentication entities communications security commons products commands

python manage.py runserver

# Fechando script
echo 'Saindo...'
exit 0
