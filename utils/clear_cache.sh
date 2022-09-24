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
./tap_text.sh "Storage[^>]*cache"
./tap_text.sh "Clear cache"

