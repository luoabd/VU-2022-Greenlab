#! /bin/bash

adb shell "dumpsys activity activities | grep mResumedActivity" | grep -o "[^ ]*/" | grep -o "[^/]*"

