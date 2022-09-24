#! /bin/bash



if [ $(adb devices -l | wc -l) -lt 3 ]
then
   echo "No device connected!"
   exit 1
fi

echo -n "Stopping all running apps..."
for app in $(adb shell ps | grep apps | awk '{print $9}')
do
   adb shell am force-stop $app
done
echo "Done"

echo "Disabling NFC"
adb shell svc nfc disable
echo "Turning off mobile data"
adb shell svc data disable
echo "Turning off battery saver"
adb shell settings put global low_power 1
echo "Dimming screen"
adb shell settings put system screen_brightness 0
echo "Turning on airplane mode, but keep Wi-Fi"
adb shell settings put global airplane_mode_radios wifi
adb shell settings put global airplane_mode_on 1
adb shell settings delete global airplane_mode_radios >/dev/null # Reset custom airplane settings
echo "Muting media playback"
music_volume=$(adb shell dumpsys audio | grep -A5 "^- STREAM_MUSIC:" | tail -n 1 | grep -o "[0-9]*$")
if [ $music_volume -gt 0 ]
then
   adb shell input keyevent 164
fi

# TODO we may decide to not clear data between runs (if so, exit script here)
cd "$(dirname "$0")"
cd ../apks

for app in $(ls | grep ".apk$")
do
   package=$(aapt dump badging $app | grep package | awk '{print $2}' | sed s/name=//g | sed s/\'// | sed s/\'//)
   echo -n "Clearing user data for $package..."
   adb shell pm clear $package
done

echo -e "\nDone!" 
