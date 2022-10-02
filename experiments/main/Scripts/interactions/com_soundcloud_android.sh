#! /bin/bash

# precondition: SoundCloud app is already opened (logged in)
# postcondition: endless playback of random songs (player maximized)

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

# Open playlist on landing page
adb shell input tap 250 850
sleep 1
# Start playback
adb shell input tap 250 1550
sleep 1
# Maximize player
adb shell input tap 250 2000

