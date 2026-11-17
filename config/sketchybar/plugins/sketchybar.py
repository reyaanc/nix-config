import subprocess

CHAR_WIDTH = 7.8
ROW_END_PADDING = 12


def colors(*names):
    script = 'source "$CONFIG_DIR/colors.sh"; echo ' + ' '.join('$' + name for name in names)
    values = subprocess.run(['/bin/bash', '-c', script], capture_output=True, text=True).stdout.split()
    return dict(zip(names, values))


def label_width(chars):
    return f'label.width={int(chars * CHAR_WIDTH) + ROW_END_PADDING}'
