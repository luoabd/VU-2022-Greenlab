#! /bin/bash

# precondition: linkedin.com is already opened in browser
# postcondition: Scrolling through feed and jobs

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

while true
do
    # Scroll feed
    # adb shell input swipe 500 1000 500 1100
    adb shell input tap 75 2250
    for _ in {1..10}
    do
        adb shell input swipe 500 2000 500 100
        sleep 1
    done
    # Scroll jobs
    # adb shell input swipe 500 1000 500 1100
    adb shell input tap 1000 2250
    sleep 1
    adb shell input tap 250 710
    sleep 1
    for _ in {1..10}
    do
        adb shell input swipe 500 2000 500 100
        sleep 1
    done
done


exit
# Below: Interaction for login (not used)


# Log in
cd "$(dirname "$0")"
USER=$(cat credentials.csv | grep "^linkedin" | awk -F "," '{print $2}')
PASS=$(cat credentials.csv | grep "^linkedin" | awk -F "," '{print $3}')
sleep 1
# Continue using web app
adb shell input tap 700 1050
# Accept cookies
adb shell input tap 700 550
sleep 1
adb shell input tap 700 700
adb shell input text "$USER"
adb shell input keyevent 66
adb shell input text "$PASS"
adb shell input keyevent 66
sleep 1
