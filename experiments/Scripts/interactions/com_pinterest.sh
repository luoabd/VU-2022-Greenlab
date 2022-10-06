#! /bin/bash

# precondition: Pinterest app is already opened (logged in)
# postcondition: Scrolled through and opened posts for 6 minutes

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

# Loop for 360 seconds (6 minutes)
START=$(date +%s)
while [ $(($(date +%s) - $START)) -lt 345 ] # Leave 15 seconds slack for the last interaction
do
    # Main interaction loop (takes roughly 11 seconds)
    # Scroll down
    adb shell input swipe 500 2000 500 1000
    adb shell input swipe 500 2000 500 1000
    adb shell input swipe 500 2000 500 1000
    # Open post
    adb shell input tap 300 1000
    adb shell input swipe 500 800 500 200
    adb shell input swipe 500 800 500 200
    adb shell input swipe 500 800 500 200
    sleep 1
    # Go back
    adb shell input keyevent 4
    # In case we opened an ad on accident go back using back button
    adb shell input tap 50 150
done
