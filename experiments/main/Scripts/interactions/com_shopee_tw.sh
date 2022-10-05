#! /bin/bash

# precondition: Shopee app is already opened
# postcondition: 

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

START=$(date +%s)
init=1

# TODO: Adjust values for test device

# Wait for the initial ad
sleep 13
# Close ad pop-up
adb shell input tap 645 400
# Open list of categories
adb shell input tap 615 450
# Open category
adb shell input tap 615 300
sleep 1

while [ $(($(date +%s) - $START)) -lt 320 ] # Leave about 5 seconds slack for the last interaction
do
    # Main interaction loop (takes roughly 35 seconds)
    # Skip the multiple promotions
    if [ $init == 1 ]; then
        adb shell input swipe 500 1300 500 250
        sleep 1
        adb shell input swipe 500 1300 500 250
        sleep 1
        adb shell input swipe 500 1300 500 250
        sleep 1
    fi
    let "init=0" 

    # Open product
    adb shell input tap 150 375
    sleep 3

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
    adb shell input swipe 500 1300 500 250
    sleep 2

done
