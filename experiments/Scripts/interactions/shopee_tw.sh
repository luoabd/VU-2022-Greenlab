#! /bin/bash

# precondition: shopee.tw is already opened in the browser
# postcondition: 

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

START=$(date +%s)

# Wait for any ad pop-up to appear
sleep 3
# Close ad pop-up
adb shell input tap 20 150
# Open category
adb shell input tap 830 650
sleep 1

while true
do
    # Main interaction loop (takes roughly 35 seconds)
    # Scroll down
    adb shell input swipe 500 1300 500 50
    sleep 1
    adb shell input swipe 500 1300 500 50
    sleep 1
    adb shell input swipe 500 1300 500 50
    sleep 1
    adb shell input swipe 500 1300 500 50
    sleep 3

    # Open product
    adb shell input tap 200 1122
    sleep 3

    # Scroll right (product images)
    adb shell input swipe 600 500 35 500
    sleep 2
    adb shell input swipe 600 500 35 500
    sleep 2
    adb shell input swipe 600 500 35 500
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
done
