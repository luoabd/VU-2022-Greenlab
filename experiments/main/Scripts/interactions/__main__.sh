#! /bin/bash

cd "$(dirname "$0")"

subject=$1
if [ -z "$subject" ]; then
    subject=$(../../../../utils/current_app.sh)
fi

if [ -z "$(which cowsay)" ]; then
    echo "Subject: $subject"
else
    cowsay "Subject: $subject"
fi

./$(echo $subject | sed -r 's/\./_/g').sh
