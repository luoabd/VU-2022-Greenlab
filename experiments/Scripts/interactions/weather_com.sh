#! /bin/bash

# precondition: weather.com is already opened in the browser
# postcondition: Viewed hourly and 10 day forecast and radar for 6 minutes

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

START=$(date +%s)

# Close cookie notice
sleep 2
adb shell input tap 700 1850
sleep 2

# Loop for 360 seconds (6 minutes)
while true
do
    # Main interaction loop (takes roughly 27 seconds)
    # hourly forecast
    adb shell input tap 300 2050
    sleep 1
    adb shell input swipe 500 2000 500 500
    sleep 1
    adb shell input swipe 500 2000 500 500
    sleep 1
    adb shell input swipe 500 2000 500 500
    sleep 3
    # 10 day forecast
    adb shell input tap 550 2200
    sleep 1
    adb shell input swipe 500 2000 500 500
    sleep 3
    # Radar
    adb shell input tap 750 2200
    sleep 10
done
