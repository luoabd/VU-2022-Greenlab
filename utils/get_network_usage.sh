#!/bin/bash

# Echo the total number of received bytes and the total number of transmitted bytes
# Based on https://gist.github.com/Zibri/387f0bd0acf09f71384ce78dd45aa058

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
    rb=$((rb/2)); # divide by 2 because this includes both the stats under Dev and Xt
    for a in $(adb shell dumpsys netstats|grep "rb="|cut -d "=" -f 5|cut -d " " -f 1);
    do
        tb=$((tb+a));
    done;
    tb=$((tb/2)); # divide by 2 because this includes both the stats under Dev and Xt
    echo $rb
    echo $tb
};
getUsage
