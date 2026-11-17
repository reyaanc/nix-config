#!/usr/bin/env -S uv run --script
# /// script
# dependencies = ["icalendar>=7.3.0", "recurring-ical-events>=3.8.2"]
# ///
import json
import os
import subprocess
import time
import urllib.request
from datetime import datetime, timedelta, timezone

from sketchybar import CHAR_WIDTH, colors

MEETING_WINDOW_MINUTES = 60
SOON_MINUTES = 10
DATA_DIR = os.path.expanduser('~/.local/share/sketchybar')
ICS_URL_FILE = os.path.join(DATA_DIR, 'ics-url')
EVENTS_FILE = os.path.join(DATA_DIR, 'events.json')
REFRESH_SECONDS = 600
RETRY_SECONDS = 120
CALENDAR_URL = 'https://calendar.google.com/calendar/r/day'
NOTCH_WIDTH = 200
RESERVED_WIDTH = 54
MIN_LABEL_CHARS = 10
MAX_LABEL_CHARS = 36
SCROLL_SPEED = 40


def query(target):
    return json.loads(subprocess.run(['sketchybar', '--query', target], capture_output=True).stdout)


def label_room():
    # A query answered mid-reload, or naming a display the other doesn't list, used to crash this and freeze the last label.
    try:
        frames = {f'display-{d["arrangement-id"]}': d['frame'] for d in query('displays')}
        rects = query('spaces')['bounding_rects']
    except ValueError:
        return 0
    rooms = [frames[k]['x'] + (frames[k]['w'] - NOTCH_WIDTH) / 2 - r['origin'][0] - r['size'][0]
             for k, r in rects.items() if k in frames]
    return int((min(rooms) - RESERVED_WIDTH) / CHAR_WIDTH) if rooms else 0


def utc(value):
    # Invites keep their organiser's offset, and floating times have none, so comparing them needs one zone; dates (all-day) pass through
    return value.astimezone(timezone.utc) if isinstance(value, datetime) else value


def fetch_events(now):
    # Only a refresh needs these, and most runs are hover and layout events that read the cache
    import icalendar
    import recurring_ical_events

    with open(ICS_URL_FILE) as f:
        url = f.read().strip()
    with urllib.request.urlopen(url, timeout=10) as response:
        calendar = icalendar.Calendar.from_ical(response.read())
    # Google names a calendar after its owner's address, which is how the owner appears among attendees.
    owner = 'mailto:' + str(calendar.get('x-wr-calname', '')).lower()
    events = []
    for component in recurring_ical_events.of(calendar).between(now, now + timedelta(days=1)):
        attendees = component.get('attendee', [])
        attendees = attendees if isinstance(attendees, list) else [attendees]
        declined = any(str(a).lower() == owner and a.params.get('PARTSTAT') == 'DECLINED' for a in attendees)
        if component.get('status') == 'CANCELLED' or declined:
            continue
        start = utc(component.decoded('dtstart'))
        end = utc(component.decoded('dtend')) if 'dtend' in component else start
        events.append({'title': str(component.get('summary') or '(no title)'),
                       'location': str(component.get('location') or ''),
                       'start': start.isoformat(), 'end': end.isoformat(),
                       'all_day': not isinstance(start, datetime)})
    return sorted(events, key=lambda e: e['start'])


def calendar_events(now):
    if not os.path.exists(EVENTS_FILE) or time.time() - os.path.getmtime(EVENTS_FILE) > REFRESH_SECONDS:
        try:
            events = fetch_events(now)
            with open(EVENTS_FILE + '.tmp', 'w') as f:
                json.dump(events, f)
            os.replace(EVENTS_FILE + '.tmp', EVENTS_FILE)
        except OSError:
            # Offline, retrying every run would queue each one behind a timeout; pushing the cache's age back retries in a couple of minutes
            if os.path.exists(EVENTS_FILE):
                retry_at = time.time() - REFRESH_SECONDS + RETRY_SECONDS
                os.utime(EVENTS_FILE, (retry_at, retry_at))
    try:
        with open(EVENTS_FILE) as f:
            return json.load(f)
    except OSError:
        return []


def next_meeting(events, now):
    for event in events:
        if event['all_day']:
            continue
        start = datetime.fromisoformat(event['start'])
        if datetime.fromisoformat(event['end']) <= now:
            continue
        minutes = (start - now).total_seconds() / 60
        if minutes <= MEETING_WINDOW_MINUTES:
            return event, minutes
        return None
    return None


def main():
    name = os.environ['NAME']
    sender = os.environ.get('SENDER')
    # Sketchybar only starts a scroll on an update right after the item's script ran; agenda_scroll is that update.
    if sender == 'mouse.entered':
        subprocess.run(['sketchybar', '--set', name, 'scroll_texts=on', '--trigger', 'agenda_scroll'])
    elif sender == 'mouse.exited':
        subprocess.run(['sketchybar', '--set', name, 'scroll_texts=off'])
    if sender in ('mouse.entered', 'mouse.exited', 'agenda_scroll'):
        return
    now = datetime.now(timezone.utc)
    meeting = next_meeting(calendar_events(now), now)
    room = label_room()
    if not meeting or room < MIN_LABEL_CHARS:
        subprocess.run(['sketchybar', '--set', name, 'drawing=off'])
        return

    c = colors('ACCENT', 'WARN', 'SUBTEXT')
    event, minutes = meeting
    if minutes <= 0:
        when, color = 'now', c['ACCENT']
    else:
        when, color = f'in {int(minutes + 0.999)}m', c['WARN'] if minutes <= SOON_MINUTES else c['SUBTEXT']
    location = event['location'] or ''
    target = location if location.startswith('http') else CALENDAR_URL
    args = ['icon=', f'icon.color={color}', f'label={when}  {event["title"]}', f'label.color={color}',
            f"click_script=open '{target}'"]

    chars = min(room, MAX_LABEL_CHARS)
    subprocess.run(['sketchybar', '--set', name, 'drawing=on', f'label.max_chars={chars}',
                    f'label.scroll_duration={int(chars * CHAR_WIDTH * 60 / SCROLL_SPEED)}', *args])


main()
