#!/bin/bash

cd "$(dirname "$0")"
cd ../apks

# Override any old summary file
echo -n "" > summary.txt

echo -n "Generating $(pwd)/summary.txt..."

for app in $(ls | grep ".apk$")
do
    echo "[$app ($(md5sum $app | awk '{ print $1 }'))]" >> summary.txt
    aapt dump badging $app 2>/dev/null | head -n 1 >> summary.txt
    echo "" >> summary.txt
done

echo "Done!"
