//
//  WifiPreferences.h
//  wifi_monitor
//
//  Copyright 2008.
//


@interface WifiPreferences : NSObject {
	CFStringRef appID;
	NSNumber *IPVersion;
	NSString *interface;
	NSString *SSID;
	NSURL *loginURL;
	NSString *POSTData;
}

- (id) init;

- (void) loadPrefs;
- (void) storePrefs:(const char **)prefarray size:(int)size;

- (const char *) retrieveUsername;
- (void) retrieveKeychainData;

- (NSNumber *) getIpVersion;
- (void) setIpVersion:(NSNumber *)ipVer;

- (NSString *) getInterface;
- (void) setInterface:(NSString *)interface;

- (NSString *) getSSID;
- (void) setSSID:(NSString *)ssid;

- (NSURL *) getLoginUrl;
- (void) setLoginUrl:(NSString *)url;

- (NSString *) getPOSTData;
- (void) setPOSTData:(NSString *)data;

- (void) dealloc;

@end
