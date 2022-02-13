#!/bin/bash
#
COMMAND=$1

# Definindo o path do projeto
project_system='melinux_web'
cd ~/${project_system} || return

# Iniciando virtualenv
env=~/venvs/venv_melinux/bin/activate
echo 'Ativando ambiente virtual'
source ${env}

if [ -z "$COMMAND" ]
then
  echo "OPTIONS: [runserver, pip_install, pip_uninstall, manager_pip, makemigrations, migrate, db_clean, bower_install"
  echo "USAGE: start_project.sh <option>"
fi
if [ "$COMMAND" = "runserver" ]
then
  python manage.py runserver 0.0.0.0:9000
fi
if [ "$COMMAND" = "pip_uninstall" ]
then
  python manager_pip.py uninstall
fi
if [ "$COMMAND" = "pip_install" ]
then
  python manager_pip.py install
fi
if [ "$COMMAND" = "makemigrations" ]
then
  python manage.py makemigrations
fi
if [ "$COMMAND" = "migrate" ]
then
  python manage.py migrate
fi
if [ "$COMMAND" = "bower_install" ]
then
  python manage.py bower_install
fi
if [ "$COMMAND" = "db_clean" ]
then
  python manage.py db_clean authentication entities communications security commons products commands
fi