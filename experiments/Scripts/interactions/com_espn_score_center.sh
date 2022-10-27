#! /bin/bash

# precondition: ESPN app (Dutch location) is already opened
# postcondition: 

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

# Scroll down (to top headlines)
sleep 1
adb shell input tap 550 550

while true
do
    # Main interaction loop

    # Scroll down
    adb shell input swipe 500 1300 500 250
    sleep 10

done
