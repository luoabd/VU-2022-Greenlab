#! /bin/bash

# precondition: soundcloud.com is already opened in the browser (NOT logged in)
# postcondition: endless playback of random songs (player maximized)

# Check device resolution
test "$(adb shell wm size | grep -oP "\d.*$")" == "1080x2340" || echo "Warning! Expected 1080x2340 device."

# Wait for any cookie pop-up to appear
sleep 3
# Start song on landing page OR accept cookie pop-up
adb shell input tap 250 1800
# Maximize player OR start song on landing page if cookie pop-up did appear
adb shell input tap 250 1800
sleep 2
# Maximize player if cookie pop-up did appear
adb shell input tap 290 1850

