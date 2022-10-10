#! /bin/bash

# precondition: espn.com is already opened in the browser
# postcondition: 

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

distance=60 # Distance between headlines
loc=1340

while true
do
    for i in {0..7}
    do
        # Main interaction loop
        # Scroll down (to top headlines)        
        adb shell input swipe 500 550 500 0
        adb shell input swipe 500 550 500 0
        sleep 1

        # Open article
        let "loc+=($distance*$i)"
        adb shell input tap 130 $loc
        sleep 2

        # Scroll down
        adb shell input swipe 500 1300 500 250
        sleep 10
        adb shell input swipe 500 1300 500 250
        sleep 10
        adb shell input swipe 500 1300 500 250
        sleep 20

        # Go back to the previous page
        adb shell input keyevent 4
        sleep 3
    done

done
