#! /bin/bash

if [ $(adb devices -l | wc -l) -lt 3 ]
then
   echo "No device connected!"
   exit 1
fi

echo "Trying to unlock device..."
adb shell input keyevent 82;sleep 1;adb shell input keyevent 82

echo "Enabling \"Stay awake\""
adb shell svc power stayon true

if [ ! -z "$(echo $@ | grep -P "\bkillall\b")" ]
then
   echo -n "Stopping all running apps..."
   # Get all processes by the user or the system which are a package name e.g. "com.myapp"
   running=$(adb shell ps | grep "^[us]" | awk '{print $9}' | grep "^[^\.].*\.")
   for app in $running
   do
      adb shell am force-stop $app
   done
   echo "Done"
fi

echo "Disabling NFC"
adb shell svc nfc disable
echo "Turning off mobile data"
adb shell svc data disable
echo "Turning on airplane mode, but keeping Wi-Fi on"
adb shell settings put global airplane_mode_radios wifi
adb shell settings put global airplane_mode_on 1
adb shell settings delete global airplane_mode_radios >/dev/null # Reset custom airplane settings
echo "Dimming screen"
adb shell settings put system screen_brightness 0
echo "Muting media playback"
music_volume=$(adb shell dumpsys audio | grep -A5 "^- STREAM_MUSIC:" | tail -n 1 | grep -o "[0-9]*$")
if [ $music_volume -gt 0 ]
then
   adb shell input keyevent 164
fi

if [ ! -z "$(echo $@ | grep -P "\bclear\b")" ]
then
   cd "$(dirname "$0")"
   cd ../apks

   for app in $(ls | grep ".apk$")
   do
      package=$(aapt dump badging $app | grep package | awk '{print $2}' | sed s/name=//g | sed s/\'// | sed s/\'//)
      echo -n "Clearing user data for $package..."
      adb shell pm clear $package
   done
fi

adb shell input keyevent KEYCODE_HOME # Make that is home
sleep 3 # Wait a bit for everything to settle
echo -e "\nDone!" 
