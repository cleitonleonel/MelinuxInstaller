#!/bin/bash

# Definindo o path do projeto
echo 'Path do projeto'
project_system='melinux_web'
cd /home/${project_system} || return

# Iniciando virtualenv
env='/home/venv_melinux/bin/activate'
echo 'Ativando ambiente virtual'
source ${env}

# Starting projeto
py="/home/venv_melinux/bin/python3"
run="manage.py runserver 0.0.0.0:9000"
${py} ${run}
