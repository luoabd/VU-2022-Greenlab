#! /bin/bash

# precondition: The Weather Channel app is already opened
# postcondition: Viewed hourly and 10 day forecast and radar for 6 minutes

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

START=$(date +%s)

# App takes a while to open
sleep 5

# Loop for 360 seconds (6 minutes)
while true
do
    # Main interaction loop (takes roughly 108 seconds)
    # hourly forecast
    adb shell input tap 100 2200
    sleep 1
    adb shell input swipe 500 2000 500 500
    sleep 1
    adb shell input swipe 500 2000 500 500
    sleep 1
    adb shell input swipe 500 2000 500 500
    sleep 1
    # 10 day forecast
    adb shell input tap 300 2200
    sleep 1
    for i in {1..9}
    do
        adb shell input tap 30 350
        sleep 1
        adb shell input swipe 500 2000 500 500
        # Scroll back to start
        adb shell input swipe 100 350 1000 350
        # Scroll to day
        for j in $(seq $i)
        do
            adb shell input swipe 195 350 0 350
        done
        sleep 1
    done
    # Radar
    adb shell input tap 750 2200
    sleep 5
done
