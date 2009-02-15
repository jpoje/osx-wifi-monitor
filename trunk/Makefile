CFLAGS = -O2 -Wall
FRAMEWORKS = -framework ApplicationServices -framework CoreFoundation -framework Foundation -framework Security -framework SystemConfiguration


default: build/wifi_monitor

build/wifi_monitor: src/WifiMonitor.m src/WifiMonitor.h src/WifiPreferences.m src/WifiPreferences.h
	-mkdir build
	gcc ${CFLAGS} ${FRAMEWORKS} src/*m -o build/wifi_monitor

install: build/wifi_monitor
	install build/wifi_monitor /usr/local/bin
	install -m 0644 dist_skel/WifiMonitor/resources/WifiMonitor.plist ~/Library/LaunchAgents

uninstall:
	-rm -f /usr/local/bin/wifi_monitor
	-rm -f ~/Library/LaunchAgents/WifiMonitor.plist

package: build/wifi_monitor
	cp -R dist_skel/ build/dist/
	cp doc/wifi_monitor.1 build/dist/WifiMonitor/doc/
	cp doc/README.txt build/dist/WifiMonitor/
	cp build/wifi_monitor build/dist/WifiMonitor/resources/
	export COPYFILE_DISABLE=true
	tar czf build/WifiMonitor-${VERSION}.tgz -C build/dist WifiMonitor/

clean:
	-rm -rf build

