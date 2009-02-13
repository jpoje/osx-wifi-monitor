#!/bin/bash


echo Act when associating to this SSID:
read -e SSID
echo Log in to this URL:
read -e URL
echo Log in with this POST data:
read -e POST

install resources/wifi_monitor /usr/local/bin
wifi_monitor -storePrefs -ssid=$SSID -login_url=$URL -post_data=$POST
install -m 0664 resources/WifiMonitor.plist ~/Library/LaunchAgents
launchctl load ~/Library/LaunchAgents/WifiMonitor.plist

