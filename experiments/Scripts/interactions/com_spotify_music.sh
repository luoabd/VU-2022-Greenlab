#! /bin/bash

# precondition: Spotify app is already opened (logged in and initial setup done)
# postcondition: playlist is playing (player NOT maximized)

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

# Open search
adb shell input keyevent 84
# Look up long playlist
adb shell input text "beatport\ top\ 100\ house"
adb shell input keyevent 66

# Open playlist
adb shell input tap 200 500

# Play shuffle
adb shell input tap 1000 1150
