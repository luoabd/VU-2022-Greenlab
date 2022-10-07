#! /bin/bash

# precondition: Coupang app is already opened
# postcondition: 

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

START=$(date +%s)
init=1


# Wait for native app to load
sleep 3
# Close initial pop-up
adb shell input tap 900 1350
sleep 1

# Open category
adb shell input tap 130 1050
sleep 1

while true
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
    adb shell input tap 175 550
    sleep 3

    # Scroll right (product images)
    adb shell input swipe 490 450 50 450
    sleep 2
    adb shell input swipe 490 450 50 450
    sleep 2
    adb shell input swipe 490 450 50 450
    sleep 2

    # Scroll down check comments)
    adb shell input swipe 500 1300 500 50
    sleep 1
    adb shell input swipe 500 1300 500 50
    sleep 1
    adb shell input swipe 500 1300 500 50
    sleep 2

    # Go back to the previous page
    adb shell input keyevent 4
    sleep 3

    # Scroll down 
    adb shell input swipe 500 1500 500 50
    adb shell input swipe 500 1500 500 50
    sleep 2
done
