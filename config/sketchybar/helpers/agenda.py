#!/usr/bin/env -S uv run --script
# /// script
# dependencies = ["icalendar>=7.3.0", "recurring-ical-events>=3.8.2"]
# ///
import json
import os
import re
import urllib.request
from datetime import datetime, timedelta, timezone

import icalendar
import recurring_ical_events

DATA_DIR = os.path.expanduser('~/.local/share/sketchybar')
ICS_URL_FILE = os.path.join(DATA_DIR, 'ics-url')
EVENTS_FILE = os.path.join(DATA_DIR, 'events.json')
MEETING_LINK = re.compile(r'https://(?:[\w-]+\.)?(?:meet\.google\.com|zoom\.us|teams\.microsoft\.com)/[^\s"<>]+')


def join_link(component):
    # Google keeps the Meet link in its own property; Zoom and Teams invites paste theirs into the location or description
    conference = component.get('x-google-conference')
    if conference:
        return str(conference)
    location = str(component.get('location') or '')
    for text in (location, str(component.get('description') or '')):
        match = MEETING_LINK.search(text)
        if match:
            return match.group()
    return location if location.startswith('http') else ''


def declined(component, owner):
    attendees = component.get('attendee', [])
    attendees = attendees if isinstance(attendees, list) else [attendees]
    return any(str(a).lower() == owner and a.params.get('PARTSTAT') == 'DECLINED' for a in attendees)


def meetings(calendar, now):
    # Google names a calendar after its owner's address, which is how the owner appears among attendees.
    owner = 'mailto:' + str(calendar.get('x-wr-calname', '')).lower()
    for component in recurring_ical_events.of(calendar).between(now, now + timedelta(days=1)):
        start = component.decoded('dtstart')
        # All-day events are dates, not times, and never count as a meeting to count down to
        if not isinstance(start, datetime) or component.get('status') == 'CANCELLED' or declined(component, owner):
            continue
        end = component.decoded('dtend') if 'dtend' in component else start
        # Floating times have no offset, and timestamp() reads those as local time, as calendars do
        yield {'title': str(component.get('summary') or '(no title)'),
               'url': join_link(component),
               'start': int(start.timestamp()),
               'end': int(end.timestamp())}


def main():
    with open(ICS_URL_FILE) as f:
        url = f.read().strip()
    with urllib.request.urlopen(url, timeout=10) as response:
        calendar = icalendar.Calendar.from_ical(response.read())

    events = sorted(meetings(calendar, datetime.now(timezone.utc)), key=lambda event: event['start'])
    with open(EVENTS_FILE + '.tmp', 'w') as f:
        json.dump(events, f)
    os.replace(EVENTS_FILE + '.tmp', EVENTS_FILE)
    print(json.dumps(events))


main()
