#! /bin/bash

echo "Clearing Chrome browser data..."
adb shell monkey -p com.android.chrome -c android.intent.category.LAUNCHER 1 2>/dev/null 1>/dev/null
sleep 1
# Close all tabs
adb shell input tap 900 150
adb shell input keyevent 82
adb shell input tap 700 400
# Clear browsing data
adb shell input keyevent 82
# for i in {1..17}
# do
#     adb shell input keyevent 20
# done
# adb shell input keyevent 66
adb shell input tap 700 650
adb shell input tap 700 1550
adb shell input tap 700 350
adb shell input tap 950 2200
