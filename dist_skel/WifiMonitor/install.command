#!/bin/bash


echo Act when associating to this SSID:
read -e SSID
echo Log in to this URL:
read -e URL
echo Log in with this POST data:
read -e POST

echo

P=`which $0`
P=`dirname $P`
sudo install $P/resources/wifi_monitor /usr/local/bin
wifi_monitor -storePrefs -ssid=$SSID -login_url=$URL -post_data=$POST
install -m 0644 $P/resources/WifiMonitor.plist ~/Library/LaunchAgents/WifiMonitor.plist

echo
echo INSTALL COMPLETE - wifi_monitor will run automatically the next time you log in.
