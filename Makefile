CFLAGS = -O2 -Wall
FRAMEWORKS = -framework ApplicationServices -framework CoreFoundation -framework Foundation -framework Security -framework SystemConfiguration


default: build/wifi_monitor

build/wifi_monitor: src/WifiMonitor.m src/WifiMonitor.h src/WifiPreferences.m src/WifiPreferences.h
	-mkdir build
	gcc ${CFLAGS} ${FRAMEWORKS} src/*m -o build/wifi_monitor

install: build/wifi_monitor
	install build/wifi_monitor /usr/local/bin
	install -m 0664 src/WifiMonitor.plist ~/Library/LaunchAgents
	launchctl load ~/Library/LaunchAgents/WifiMonitor.plist

uninstall:
	-rm -f /usr/local/bin/wifi_monitor
	-rm -f ~/Library/LaunchAgents/WifiMonitor.plist

package: build/wifi_monitor
	cp -R src/dist/ build/dist/
	cp doc/wifi_monitor.1 build/dist/WifiMonitor/doc/
	cp doc/README build/dist/WifiMonitor/
	cp build/wifi_monitor build/dist/WifiMonitor/resources/
	cp src/WifiMonitor.plist build/dist/WifiMonitor/resources/
	export COPYFILE_DISABLE=true
	tar czf build/WifiMonitor-${VERSION}.tgz -C build/dist WifiMonitor/

clean:
	-rm -rf build

