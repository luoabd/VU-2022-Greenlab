#! /bin/bash

# precondition: ESPN app (Dutch location) is already opened
# postcondition: 

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

distance=60 # Distance between headlines
loc=790

# Scroll down (to top headlines)
adb shell input swipe 500 2000 500 50
sleep 1

while true
do
    for i in {0..7}
    do
        # Main interaction loop
        # Open article
        let "loc+=($distance*$i)"
        adb shell input tap 130 $loc
        sleep 2

        # Scroll down
        adb shell input swipe 500 1300 500 250
        sleep 1
        adb shell input swipe 500 1300 500 250
        sleep 1
        adb shell input swipe 500 1300 500 250
        sleep 2

        # Go back to the previous page
        adb shell input keyevent 4
        sleep 3
    done

done
