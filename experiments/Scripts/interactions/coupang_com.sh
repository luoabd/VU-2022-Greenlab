#! /bin/bash

# precondition: coupang.com is already opened in the browser
# postcondition: 

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

START=$(date +%s)
iter=1

# Wait for native app ad pop-up to appear and close it
sleep 3
adb shell input tap 600 1300

# Open category
adb shell input tap 950 950
sleep 1

while true
do
    # Main interaction loop (takes roughly 35 seconds)
    # Open product
    adb shell input tap 105 850
    sleep 3
    # Close the native app pop-up if it showed up
    adb shell input tap 600 1300

    # Scroll right (product images)
    adb shell input swipe 490 450 250 450
    sleep 2
    adb shell input swipe 490 450 250 450
    sleep 2
    adb shell input swipe 490 450 250 450
    sleep 2

    # Scroll down check comments)
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

    let "iter+=1" 
    if [ $(expr $iter % 5) == "0" ]; then
        # Go to next page
        adb shell input swipe 500 1300 500 250
        adb shell input tap 800 850
        sleep 3
    fi
done
