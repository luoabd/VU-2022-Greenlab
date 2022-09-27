#!/bin/bash
# Get android network usage statistics from phone.
# by Zibri
function getUsage () 
{ 
    rb=0;
    tb=0;
    for a in $(adb shell dumpsys netstats|grep "rb="|cut -d "=" -f 3|cut -d " " -f 1);
    do
        rb=$((rb+a));
    done;
    rb=$((rb/2));
    for a in $(adb shell dumpsys netstats|grep "rb="|cut -d "=" -f 5|cut -d " " -f 1);
    do
        tb=$((tb+a));
    done;
    tb=$((tb/2));
    echo $rb
    echo $tb
#    echo Total: $(((rb+tb)/1024)) Mb
};
getUsage
