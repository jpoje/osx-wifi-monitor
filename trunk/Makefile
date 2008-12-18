default: build/wifi_monitor

build/wifi_monitor: src/WifiMonitor.m src/WifiMonitor.h src/WifiPreferences.m src/WifiPreferences.h
	-mkdir build
	gcc src/*m -Wall -O2 -o build/wifi_monitor -framework ApplicationServices -framework CoreFoundation -framework Foundation -framework Security -framework SystemConfiguration

install: build/wifi_monitor
	install build/wifi_monitor /usr/local/bin
	install -m 0664 src/WifiMonitor.plist ~/Library/LaunchAgents

clean:
	-rm -rf build

