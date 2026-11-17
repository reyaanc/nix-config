#!/bin/bash

# Sketchybar starts a script for every event without waiting for the last run, so a slow run can land after a newer one:
# a hover popup reopening after the mouse has left, or an old value painted over a fresh one. Queue each item's runs instead.
exec /usr/bin/lockf -k "/tmp/sketchybar/$NAME.lock" "$@"
