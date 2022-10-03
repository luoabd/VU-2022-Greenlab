#! /bin/bash

# precondition: Twitch app is already opened (logged in, dismissed initial pop-ups)
# postcondition: live stream is playing (24/7)

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

# Open search
adb shell input tap 950 2250
sleep 1
# Look up 24/7 stream (animals)
adb shell input text 'CritterVision'
adb shell input keyevent 66

# Open video
adb shell input tap 200 450
