#! /bin/bash

# precondition: 
# postcondition: 

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

# Wait for any cookie pop-up to appear
sleep 1
# Accept cookies
adb shell input tap 450 1900
adb shell input swipe 450 1800 450 600
adb shell input tap 450 1650 

# Go back just in case we did just open a video (no cookie pop-up)
adb shell input tap 50 150

# Open search
adb shell input tap 900 150
# Look up 10h video (very nice music)
adb shell input text 'UcRtFYAz2Yo'
adb shell input keyevent 66

# Open video
adb shell input tap 200 450
