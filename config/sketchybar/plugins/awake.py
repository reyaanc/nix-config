#!/usr/bin/env python3
import os
import subprocess
import time

from sketchybar import colors, label_width

AWAKE = os.path.expanduser('~/.local/bin/awake')
MAX_ROWS = 6
PROJECT_CHARS = 10
TITLE_CHARS = 29
APP_FONT = 'sketchybar-app-font:Regular:14.0'
GLYPH_FONT = 'JetBrainsMono Nerd Font:Bold:14.0'
CUP = ''
HAND = ''
TERMINAL = ''


def awake(*args):
    return subprocess.run([AWAKE, *args], capture_output=True, text=True)


def holds():
    rows = [line.split('\t') for line in awake('list').stdout.splitlines()]
    rows.sort(key=lambda hold: (hold[0] == 'manual', int(hold[3])))
    return rows


def windows():
    out = subprocess.run(['aerospace', 'list-windows', '--all', '--format', '%{window-id}|%{window-title}'],
                         capture_output=True, text=True).stdout
    # Claude Code animates the glyph in front of the session title while a turn runs, so only what follows it is matched.
    return {title.split(' ', 1)[-1]: wid for wid, title in (line.split('|', 1) for line in out.splitlines() if '|' in line)}


def cut(text, chars):
    return text if len(text) <= chars else text[:chars - 1].rstrip() + '…'


def elapsed(since):
    minutes = max(0, int(time.time()) - since) // 60
    if minutes < 1:
        return '<1m'
    if minutes < 60:
        return f'{minutes}m'
    if minutes < 1440:
        return f'{minutes // 60}h{minutes % 60:02d}m'
    return f'{minutes // 1440}d{minutes % 1440 // 60:02d}h'


def main():
    name = os.environ['NAME']
    sender = os.environ.get('SENDER')
    if sender == 'mouse.exited.global':
        subprocess.run(['sketchybar', '--set', name, 'popup.drawing=off'])
        return
    if sender == 'mouse.clicked':
        awake('toggle', 'manual', '--label', 'Manual', '--ttl', '1800')

    c = colors('ACCENT', 'ORANGE', 'GREEN', 'SUBTEXT', 'DIM', 'MUTED', 'POPUP_HOVER', 'TRANSPARENT')
    held = holds()
    # The backend can take a moment to report a session it was just asked to start or end, so holds alone count as on,
    # and right after they change they alone decide: an ending session would otherwise show as started elsewhere.
    changed = sender in ('mouse.clicked', 'awake_change')
    on = bool(held) or not changed and awake('active').returncode == 0
    automatic = sum(hold[0] != 'manual' for hold in held)
    args = ['--set', name, f'icon.color={c["ACCENT"] if on else c["MUTED"]}', f'label={automatic}',
            f'label.drawing={"on" if automatic else "off"}']

    shown = held[:MAX_ROWS]
    with_detail = [hold for hold in shown if hold[2]]
    project_chars = min(PROJECT_CHARS, max((len(hold[1]) for hold in with_detail), default=0))
    title_chars = min(TITLE_CHARS, max((len(hold[2]) for hold in with_detail), default=0))
    first_chars = project_chars + 2 + title_chars if with_detail else max((len(hold[1]) for hold in shown), default=0)
    found = windows() if any(hold[0].startswith('claude-') for hold in shown) else {}

    rows = []
    for hold_id, label, detail, since in shown:
        if detail:
            text = f'{cut(label, project_chars):<{project_chars}}  {cut(detail, title_chars):<{title_chars}}'
        else:
            text = f'{cut(label, first_chars):<{first_chars}}'
        text += f'  {elapsed(int(since)):>5}'
        if hold_id.startswith('claude-'):
            wid = found.get(detail)
            click = f'sketchybar --set {name} popup.drawing=off; aerospace focus --window-id {wid}' if wid else ''
            rows.append((':claude:', APP_FONT, c['ORANGE'], text, c['SUBTEXT'], click))
        elif hold_id == 'manual':
            rows.append((HAND, GLYPH_FONT, c['ACCENT'], text, c['SUBTEXT'], f'{AWAKE} release manual; sketchybar --trigger awake_change'))
        else:
            rows.append((TERMINAL, GLYPH_FONT, c['GREEN'], text, c['SUBTEXT'], ''))
    if not held and on:
        rows.append((CUP, GLYPH_FONT, c['DIM'], 'Started elsewhere', c['SUBTEXT'], ''))

    hidden = len(held) - len(shown)
    footer = f'+{hidden} more' if hidden else ''
    chars = max([len(footer), *(len(row[3]) for row in rows)], default=0)
    width = label_width(chars)

    for i in range(MAX_ROWS):
        item = f'{name}.hold.{i}'
        if i >= len(rows):
            args += ['--set', item, 'drawing=off']
            continue
        icon, font, icon_color, text, text_color, click = rows[i]
        # Rows only show their hover background when clicking them does something.
        args += ['--set', item, 'drawing=on', f'icon={icon}', f'icon.font={font}', f'icon.color={icon_color}',
                 f'label={text}', f'label.color={text_color}', width,
                 f'background.color={c["POPUP_HOVER"] if click else c["TRANSPARENT"]}', f'click_script={click}']
    args += ['--set', f'{name}.more', f'drawing={"on" if footer else "off"}', 'icon.drawing=off',
             f'label={footer}', f'label.color={c["DIM"]}', width, f'background.color={c["TRANSPARENT"]}']

    if not rows:
        args += ['--set', name, 'popup.drawing=off']
    elif sender in ('mouse.entered', 'mouse.clicked', 'awake_change'):
        args += ['--set', name, 'popup.drawing=on']
    subprocess.run(['sketchybar', *args])


main()
