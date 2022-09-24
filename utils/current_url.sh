#! /bin/bash

cd "$(dirname "$0")"
if [ $(./current_app.sh) != "org.mozilla.firefox" ]
then
   exit 1
fi

output=$(adb exec-out uiautomator dump /dev/tty)
url=$(echo $output | grep -oE "resource-id=\"org\.mozilla\.firefox:id/mozac_browser_toolbar_origin_view\"[^>]*><[^>]*text=\"[^\"]*"| grep -oE "text=.*" | cut -c 7-)

echo $url

