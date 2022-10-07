#! /bin/bash

cd "$(dirname "$0")"

package=$1
if [ -z "$package" ]
then
   echo "Usage: $0 <package>"
   exit 1
fi

adb shell am force-stop com.android.settings
adb shell am start -a android.settings.APPLICATION_DETAILS_SETTINGS package:$package >/dev/null
sleep 1
# ./tap_text.sh "Storage[^>]*cache"
adb shell input tap 800 1300
# ./tap_text.sh "CLEAR CACHE" # "Clear cache"
adb shell input tap 800 750

