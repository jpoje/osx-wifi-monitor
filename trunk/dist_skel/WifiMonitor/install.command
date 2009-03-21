#!/bin/bash -e


echo
echo "These settings can be changed after installation, see the README."
echo "> Act when associating to this SSID (if it has spaces, see the README):"
read -e SSID
echo "> Log in to this URL:"
read -e URL
echo "> Log in with this POST data:"
read -e POST
echo

P="`which "$0"`"
P="`dirname "$P"`"

sudo install "$P"/resources/wifi_monitor /usr/local/bin

if [ -n "$SSID" ]; then
	wifi_monitor -storePrefs -ssid=$SSID
fi
if [ -n "$URL" ]; then
	wifi_monitor -storePrefs -login_url=$URL
fi
if [ -n "$POST" ]; then
	wifi_monitor -storePrefs -post_data=$POST
fi

[ -e ~/Library/LaunchAgents ] || mkdir ~/Library/LaunchAgents
install -m 0644 "$P"/resources/WifiMonitor.plist ~/Library/LaunchAgents

echo
echo INSTALL COMPLETE - wifi_monitor will run automatically the next time you log in.

