#! /bin/bash

# precondition: spotify.com is already opened in the browsers (NOT logged in)
# postcondition: playlist is playing (player NOT maximized)

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

# Open search
adb shell input tap 400 2050
adb shell input tap 400 400
sleep 1
# Look up long playlist
adb shell input text "beatport\ top\ 100\ house"
adb shell input keyevent 66
sleep 1

# Open playlist
adb shell input tap 200 500
sleep 1

# Play shuffle
adb shell input tap 1000 1150

exit

# Accept cookies
adb shell input tap 950 1800
sleep 1

# Below: Interaction for login (not used)
# Allow DRM content
adb shell input keyevent 22
adb shell input keyevent 22
adb shell input keyevent 66

cd "$(dirname "$0")"
USER=$(cat credentials.csv | grep "^spotify" | awk -F "," '{print $2}')
PASS=$(cat credentials.csv | grep "^spotify" | awk -F "," '{print $3}')
adb shell input tap 1000 150
adb shell input tap 200 350
sleep 1
adb shell input tap 400 1100
sleep 1
adb shell input text "$USER"
adb shell input keyevent 66
sleep 1
adb shell input text "$PASS"
adb shell input keyevent 66
sleep 1

# Allow DRM content
adb shell input keyevent 22
adb shell input keyevent 22
adb shell input keyevent 66