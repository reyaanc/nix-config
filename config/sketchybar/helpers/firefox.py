#!/usr/bin/env python3
import configparser
import glob
import os
import sqlite3
import subprocess
import sys

FIREFOX_DIR = os.path.expanduser('~/Library/Application Support/Firefox')


def avatars():
    found = {}
    for db in glob.glob(f'{FIREFOX_DIR}/Profile Groups/*.sqlite'):
        with sqlite3.connect(f'file:{db}?mode=ro', uri=True) as conn:
            found.update(conn.execute('select path, avatar from Profiles'))
    return found


def default_profile():
    installs = configparser.ConfigParser()
    installs.read(f'{FIREFOX_DIR}/installs.ini')
    return next((section['Default'] for section in installs.values() if 'Default' in section), None)


def command_lines(pids):
    out = subprocess.run(['ps', '-o', 'pid=,args=', '-p', ','.join(pids)], capture_output=True, text=True).stdout
    return dict(line.strip().split(' ', 1) for line in out.splitlines())


def main():
    pids = sys.argv[1:]
    if not pids:
        return
    profiles = avatars()
    default = default_profile()
    for pid, args in command_lines(pids).items():
        # Profiles opened from the profile menu get their path on the command line; one opened from the Dock is the install's default.
        path = next((p for p in profiles if f'{FIREFOX_DIR}/{p}' in args), None if '-profile ' in args else default)
        if path in profiles and path != default:
            print(f'{pid}|{profiles[path]}')


main()
