CFLAGS = -O2 -Wall
FRAMEWORKS = -framework ApplicationServices -framework CoreFoundation -framework Foundation -framework Security -framework SystemConfiguration


default: build/wifi_monitor

build/wifi_monitor: clean src/WifiMonitor.m src/WifiMonitor.h src/WifiPreferences.m src/WifiPreferences.h
	-mkdir build
	gcc ${CFLAGS} ${FRAMEWORKS} src/*m -o build/wifi_monitor

install: build/wifi_monitor
	install build/wifi_monitor /usr/local/bin
	install -m 0664 src/WifiMonitor.plist ~/Library/LaunchAgents

uninstall:
	-rm -f /usr/local/bin/wifi_monitor
	-rm -f ~/Library/LaunchAgents/WifiMonitor.plist

clean:
	-rm -rf build

