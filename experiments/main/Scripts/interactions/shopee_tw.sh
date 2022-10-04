#! /bin/bash

# precondition: shopee.tw is already opened in the browser
# postcondition: 

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

START=$(date +%s)

# TODO: Adjust values for test device
function interact() {
    # Scroll down
    adb shell input swipe 500 1300 500 250
    sleep 1
    adb shell input swipe 500 1300 500 250
    sleep 1
    adb shell input swipe 500 1300 500 250
    sleep 1
    adb shell input swipe 500 1300 500 250
    sleep 3

    # Open product
    adb shell input tap 200 1122
    sleep 3

    # Scroll right (product images)
    adb shell input swipe 600 500 135 500
    sleep 2
    adb shell input swipe 600 500 135 500
    sleep 2
    adb shell input swipe 600 500 135 500
    sleep 2

    # Scroll down
    adb shell input swipe 500 1300 500 250
    sleep 1
    adb shell input swipe 500 1300 500 250
    sleep 1
    adb shell input swipe 500 1300 500 250
    sleep 2

    # Go back to the previous page
    adb shell input tap 45 87
    sleep 3
}

# Wait for any ad pop-up to appear
sleep 3
# Open category
adb shell input tap 555 515
sleep 1

while [ $(($(date +%s) - $START)) -lt 330 ] # Leave 30 seconds slack for the last interaction
do
    # Main interaction loop (takes roughly 30 seconds)
    interact
done
