from pip.__main__ import _main as pip
from sys import platform as _sys_platform
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


class PipManager:

    def __init__(self, args):
        if args[1] == 'install':
            self.install(args)
        elif args[1] == 'upgrade':
            self.upgrade(args)
        else:
            self.uninstall(args)

    def install(self, args):
        if len(args) > 2:
            pip([args[1], args[2]])
        else:
            for package in packages:
                for line in open(package):
                    if line.startswith('@git'):
                        username = profile.GITHUB_USER
                        password = profile.GITHUB_PASSWORD
                        command = f'git+https://{username}:{password}{line}'
                        pip([args[1], command])
                    elif '==' in line:
                        pip([args[1], line])

    def upgrade(self, args):
        if len(args) > 2:
            pip(['install', '--' + args[1], args[2]])
        else:
            for package in packages:
                for line in open(package):
                    if line.startswith('@git'):
                        username = profile.GITHUB_USER
                        password = profile.GITHUB_PASSWORD
                        command = f'git+https://{username}:{password}{line}'
                        pip(['install', '-U', command])
                    elif line.startswith('git+'):
                        pip(['install', '-U', line])

    def uninstall(self, args):
        if len(args) > 2:
            pip([args[1], args[2]])
        else:
            for app in delete_apps:
                if app != 'uninstall':
                    pip([args[1], '-y', app])


def _get_platform():
    if 'P4A_BOOTSTRAP' in os.environ:
        return 'android'
    elif 'ANDROID_ARGUMENT' in os.environ:
        return 'android'
    elif _sys_platform in ('win32', 'cygwin'):
        return 'win'
    elif _sys_platform == 'darwin':
        return 'macosx'
    elif _sys_platform.startswith('linux'):
        return 'linux'
    elif _sys_platform.startswith('freebsd'):
        return 'linux'
    return 'unknown'


platform = _get_platform()


if __name__ == '__main__':
    args = sys.argv
    if len(args) > 1:
        manager = PipManager
        manager(args)
    else:
        print('Nenhum comando...')
