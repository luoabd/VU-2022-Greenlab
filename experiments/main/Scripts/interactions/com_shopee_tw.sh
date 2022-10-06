#! /bin/bash

# precondition: Shopee app is already opened
# postcondition: 

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

START=$(date +%s)
init=1

sleep 1
# Close full screen pop-up (if there is one)
adb shell input keyevent 4

# Open category
adb shell input tap 950 700
sleep 2
adb shell input tap 950 500
sleep 2

while [ $(($(date +%s) - $START)) -lt 315 ] # Leave about 5 seconds slack for the last interaction
do
    # Main interaction loop (takes roughly 40 seconds)
    # Skip the multiple promotions
    if [ $init == 1 ]; then
        adb shell input swipe 500 2000 500 50
        sleep 1
        adb shell input swipe 500 2000 500 50
        sleep 1
        adb shell input swipe 500 2000 500 50
        sleep 1
        adb shell input swipe 500 2000 500 50
        sleep 1
    fi
    let "init=0" 

    # Open product
    adb shell input tap 150 375
    sleep 4

    # Scroll right (product images)
    adb shell input swipe 600 400 35 400
    sleep 2
    adb shell input swipe 600 400 35 400
    sleep 2
    adb shell input swipe 600 400 35 400
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

    # Scroll down 
    adb shell input swipe 500 1300 500 50
    sleep 2
done
