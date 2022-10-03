#! /bin/bash

# precondition: YouTube app is already opened
# postcondition: video is playing (10h video) 

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

# Open search
adb shell input keyevent 84
# Look up 10h video (very nice music)
adb shell input text 'UcRtFYAz2Yo'
adb shell input keyevent 66
sleep 1

# Open video
adb shell input tap 200 450
