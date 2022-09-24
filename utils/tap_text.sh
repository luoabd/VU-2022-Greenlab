#! /bin/bash

text=$1
if [ -z "$text" ]
then
   echo "Usage: $0 <pattern>"
   exit 1
fi

output=$(adb exec-out uiautomator dump /dev/tty)

bounds=$(echo $output | grep -oE "text=\"$text\"[^>]*" | grep -o "bounds=\"[^\"]*" | cut -c 9-)

if [ -z "$bounds" ]
then
   echo "No such pattern!"
   exit 1
fi

x=$(echo $bounds | cut -c 2- | grep -o "^[^,]*")
x=$(($x + 1))
y=$(echo $bounds | grep -o ",[0-9]*" | head -n 1 | cut -c 2-)
y=$(($y + 1))

adb shell input tap $x $y

