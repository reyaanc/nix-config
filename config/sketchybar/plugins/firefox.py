#!/usr/bin/env python3
import configparser
import glob
import os
import sqlite3
import subprocess

FIREFOX_DIR = os.path.expanduser('~/Library/Application Support/Firefox')
CACHE = '/tmp/sketchybar/firefox'


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


def main():
    profiles = avatars()
    default = default_profile()
    pids = subprocess.run(['aerospace', 'list-windows', '--monitor', 'all', '--app-bundle-id', 'org.mozilla.firefox',
                           '--format', '%{app-pid}'], capture_output=True, text=True).stdout.split()
    text = ''
    for pid in sorted(set(pids)):
        args = subprocess.run(['ps', '-o', 'args=', '-p', pid], capture_output=True, text=True).stdout
        # Profiles opened from the profile menu get their path on the command line; one opened from the Dock is the install's default.
        path = next((p for p in profiles if f'{FIREFOX_DIR}/{p}' in args), None if '-profile ' in args else default)
        if path in profiles and path != default:
            text += f'{pid}|{profiles[path]}\n'

    if os.path.exists(CACHE) and open(CACHE).read() == text:
        return
    with open(CACHE, 'w') as f:
        f.write(text)
    subprocess.run(['sketchybar', '--trigger', 'firefox_change'])


main()
