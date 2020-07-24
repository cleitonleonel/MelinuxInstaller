#!/bin/bash

sudo chown -R $USER:$USER ./

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
if [[ "${OS}" == "Linux-x86_64" ]];
  then
    project_system='lin_melinux'
elif [[ "${OS}" == "Raspberry" ]];
  then
    project_system='arm_melinux'
fi

# Iniciando virtualenv

env='venv_melinux/bin/activate'
echo 'Ativando ambiente virtual'
source ${env}

# Starting projeto

py="/home/${project_system}/venv_melinux/bin/python"
run="manage.py runserver 0.0.0.0:9000"
${py} ${run}
