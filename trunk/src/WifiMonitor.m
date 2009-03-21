//
//  wifi_monitor.m
//  wifi_monitor
//
//  Copyright 2008.
//


#import <Cocoa/Cocoa.h>
#import <SystemConfiguration/SCDynamicStore.h>

#import "WifiPreferences.h"
#import "WifiMonitor.h"


// creates and kicks off a WifiMonitor
int main (int argc, const char *argv[]) {
 	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	if (argc > 1) {
		if (strncmp(argv[1], "-v", 2) == 0) {
			VERBOSE = 1;
		}
		
		if (argc - VERBOSE > 1) {
			// update prefs
			WifiPreferences *prefs = [[WifiPreferences alloc] init];
			[prefs storePrefs:argv size:argc];
			
			// restart daemon (if running) - popen() is an alternative
			system("kill -HUP `ps -e | grep wifi_monitor | egrep -m 1 -v \"grep|$PPID\" | awk '{print $1}'` &> /dev/null");

			// quit
			[pool release];
			return 0;
		}
	}
	
	// register our SIGHUP handler for pref reloading
	struct sigaction sig_struct;
	sig_struct.sa_handler = handleSIGHUP;
	sigemptyset(&sig_struct.sa_mask);
	sigaction(SIGHUP, &sig_struct, NULL);

	// run the daemon
	WifiMonitor *monitor = [[WifiMonitor alloc] init];
	CFRunLoopRun();
	
	[monitor release];
	[pool release];
			
    return 0;
}

// handles SIGHUP for rereading updated prefs
void handleSIGHUP(int sig) {
	prefsNeedReload = 1;
}

// call back function for state change updates - just calls reload
void updateCallBack(SCDynamicStoreRef store, CFArrayRef changedKeys, void *info) {
	[(WifiMonitor *)info reload];
}


@implementation WifiMonitor

// inits everything
- (id) init {
	[super init];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// initialize preferences
	prefs = [[WifiPreferences alloc] init];
		
	// get the dynamic store
	SCDynamicStoreContext context = {0, self, NULL, NULL, NULL};
	store = SCDynamicStoreCreate(NULL, (CFStringRef)@"WifiMonitor", updateCallBack, &context);
	
	// register for updates
	NSArray *array = [NSArray arrayWithObject:[NSString stringWithFormat:@"State:/Network/Interface/%@/IPv%@", [prefs getInterface], [prefs getIpVersion]]];
	if (!SCDynamicStoreSetNotificationKeys(store, (CFArrayRef)array, NULL)) {
		NSLog(@"failed to set notification keys");
		exit(1);
	}
	
	// get current state info
	[self reload];
	
	// create and start a run loop
	CFRunLoopSourceRef runLoopSource = SCDynamicStoreCreateRunLoopSource(NULL, store, 0);
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopDefaultMode);
	CFRelease(runLoopSource);
	
	[pool release];
	
	return self;
}

// when the status is changed we check to see if it's an SSID we need to do something for
- (void) reload {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	// reload prefs if needed
	if (prefsNeedReload) {
		prefsNeedReload = 0;
		if (VERBOSE) NSLog(@"Reading updated prefs");
		[prefs loadPrefs];
	}

	// get the updated info
	NSString *interface = [NSString stringWithFormat:@"State:/Network/Interface/%@/AirPort", [prefs getInterface]];
	NSDictionary *values = (NSDictionary *)SCDynamicStoreCopyValue(store, (CFStringRef)interface);
	
	if (VERBOSE) NSLog(@"SSID_STR: [%@]", [values objectForKey:@"SSID_STR"]);
	
	// if the SSID is what we're looking for, use HTTP(S) to log in
	if ([[values objectForKey:@"SSID_STR"] isEqualToString:[prefs getSSID]]) {
		[self execResponse];
	}
	
	[values release];
	[pool release];
}

// this executes when we associate to the appropriate SSID
- (void) execResponse {
	sleep(1);
	
	NSStringEncoding enc = NSUTF8StringEncoding;
	NSError *err;		
	NSURLResponse *response;
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[prefs getLoginUrl]];
	if ([[prefs getPOSTData] length] > 0) {
		[request setHTTPMethod:@"POST"];
		[request setHTTPBody:[[prefs getPOSTData] dataUsingEncoding:enc]];
	}
	
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
	
	if (data == nil) {
		NSLog(@"Connection failed - error: %@ %@", [err localizedDescription]
				, [[err userInfo] objectForKey:NSErrorFailingURLStringKey]);
	} else {
		NSString *s = [[NSString alloc] initWithData:data encoding:enc];
		if (VERBOSE) NSLog(@"received from POST: [%@]", s);
		[s release];
	}
}

- (void) dealloc {
	[prefs release];
	CFRelease(store);
	
	[super dealloc];
}

@end
