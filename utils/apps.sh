#! /bin/bash

if [ $(adb devices -l | wc -l) -lt 3 ]
then
   echo "No device connected!"
   exit 1
fi

cd "$(dirname "$0")"
cd ../apks

if [ "$1" == "install" ]
then
   for app in $(ls | grep ".apk$")
   do
      echo -n "Installing $app..."
      adb install $app 1>/dev/null 2>/dev/null
      echo "Done"
   done
   exit
fi

if [ "$1" == "uninstall" ]
then
   for app in $(ls | grep ".apk$")
   do
      package=$(aapt dump badging $app | grep package | awk '{print $2}' | sed s/name=//g | sed s/\'// | sed s/\'//)
      echo -n "Uninstalling $package..."
      adb uninstall $package 1>/dev/null 2>/dev/null
      echo "Done"
   done
   exit
fi

echo "Usage: $0 <install|uninstall>" 
exit 1

