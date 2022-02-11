# from pip.__main__ import _main as pip
from pip import main as pip
import os
import sys

sys.path.append(os.path.join(os.path.dirname(__file__)))

from config import profile


packages = [
    profile.REQUIREMENTS,
    profile.DEPENDENCIES
]

delete_apps = [
    "apps.core.authentication",
    "apps.core.commons",
    "apps.core.security",
    "apps.core.communications",
    "apps.core.management",
    "apps.entities",
    "apps.products",
    "apps.sales.commands"
]


class PipManager(object):

    def __init__(self, parameters):
        if parameters[1] == 'install':
            self.install(parameters)
        elif parameters[1] == 'upgrade':
            self.upgrade(parameters)
        else:
            self.uninstall(parameters)

    @staticmethod
    def install(parameters):
        print(args[1])
        if len(parameters) > 2:
            pip([parameters[1], parameters[2]])
        else:
            for package in packages:
                for line in open(package):
                    if line.startswith('@git'):
                        token = profile.GITHUB_TOKEN
                        command = f'git+https://{token}{line}'
                        print(f"pip install {command}")
                        pip([args[1], command])
                    else:
                        pip([args[1], line])

    @staticmethod
    def upgrade(parameters):
        if len(parameters) > 2:
            pip(['install', '--' + parameters[1], parameters[2]])
        else:
            for package in packages:
                for line in open(package):
                    if line.startswith('@git'):
                        token = profile.GITHUB_TOKEN
                        command = f'git+https://{token}{line}'
                        pip(['install', '-U', command])
                    elif line.startswith('git+'):
                        pip(['install', '-U', line])

    @staticmethod
    def uninstall(parameters):
        if len(parameters) > 2:
            pip([parameters[1], parameters[2]])
        else:
            for app in delete_apps:
                if app != 'uninstall':
                    pip([parameters[1], '-y', app])


if __name__ == '__main__':
    args = sys.argv
    if len(args) > 1:
        manager = PipManager(args)
    else:
        print('Nenhum comando...')
