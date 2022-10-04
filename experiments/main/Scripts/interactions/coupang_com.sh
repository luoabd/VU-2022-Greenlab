#! /bin/bash

# precondition: shopee.tw is already opened in the browser
# postcondition: 

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

START=$(date +%s)
iter=1

# TODO: Adjust values for test device
function interact() {
    # Open product
    adb shell input tap 105 850
    sleep 3

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
    (($iter % 4 == 0)) && 
    if [ $(expr $iter % 4) == "0" ]; then
        adb shell input tap 550 530
        sleep 3
    fi
}

# Wait for ad pop-up to appear and close it
sleep 3
adb shell input tap 300 932

# Open category
adb shell input tap 630 720
sleep 1

while [ $(($(date +%s) - $START)) -lt 330 ] # Leave 30 seconds slack for the last interaction
do
    # Main interaction loop (takes roughly 25 seconds)
    interact
done
