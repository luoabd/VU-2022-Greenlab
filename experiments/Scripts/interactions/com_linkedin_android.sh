#! /bin/bash

# precondition: LinkedIn app is already opened in browser
# postcondition: Scrolling through feed and jobs

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

while true
do
    # Scroll feed
    adb shell input swipe 500 1000 500 1100
    adb shell input tap 50 2200
    for _ in {1..10}
    do
        adb shell input swipe 500 2000 500 100
        sleep 1
    done
    # Scroll jobs
    adb shell input swipe 500 1000 500 1100
    adb shell input tap 950 2200
    sleep 1
    adb shell input tap 250 1250
    sleep 1
    for _ in {1..10}
    do
        adb shell input swipe 500 2000 500 100
        sleep 1
    done
    adb shell input keyevent 4
done
