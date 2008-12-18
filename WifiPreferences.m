//
//  WifiPreferences.m
//  wifi_monitor
//
//  Copyright 2008.
//


#import <Cocoa/Cocoa.h>

#import "WifiPreferences.h"

extern VERBOSE;

// These go here rather than in the header because we don't want anyone else to go mucking with them
#define KEYCHAIN_SERVICE "wifi_monitor_testing"

#define PREFS_ROOT "com.wifi_monitor"
#define PREFS_NETWORK_IPVER "IPVersion"
#define PREFS_NETWORK_INTERFACE "interface"
#define PREFS_NETWORK_SSID "SSID"
#define PREFS_LOGINURL "loginURL"


@implementation WifiPreferences

- (id) init {
	[super init];
	appID = CFSTR(PREFS_ROOT);
	
	[self loadPrefs];
	
	return self;
}

// retrieve prefs or use defaults
- (void) loadPrefs {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSNumber* ipver = (NSNumber *)CFPreferencesCopyValue(CFSTR(PREFS_NETWORK_IPVER), appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if(ipver == NULL) {
		if (VERBOSE) NSLog(@"No ip version preference found. Default is IPv4");
		[ipver release];
		IPVersion = [[NSNumber numberWithInteger:4] retain];
	} else {
		if (VERBOSE) NSLog(@"IP Version: IPv%@", ipver);
		IPVersion = ipver;
	}
	
	NSString* iface = (NSString *)CFPreferencesCopyValue(CFSTR(PREFS_NETWORK_INTERFACE), appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if(iface == NULL) {
		if (VERBOSE) NSLog(@"No interface preference found. Default is en1");
		[iface release];
		interface = [@"en1" retain];
	} else {
		if (VERBOSE) NSLog(@"Interface: %@", iface);
		interface = iface;
	}
	
	NSString* ssid = (NSString *)CFPreferencesCopyValue(CFSTR(PREFS_NETWORK_SSID), appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (ssid == NULL) {
		if (VERBOSE) NSLog(@"No SSID preference found. Default is XXXX");
		[ssid release];
		SSID = [@"XXXX" retain];
	} else {
		if (VERBOSE) NSLog(@"SSID: %@", ssid);
		SSID = ssid;
	}
	
	NSString* loginurl = (NSString *)CFPreferencesCopyValue(CFSTR(PREFS_LOGINURL), appID, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (loginurl == NULL) {
		if (VERBOSE) NSLog(@"No LoginUrl preference found. Default is https://auth.lawn.gatech.edu/index.php");
		[loginurl release];
		loginurl = [@"http://www.snee.com/xml/crud/posttest.cgi?blarg=x" retain];
	} else {
		if (VERBOSE) NSLog(@"LoginURL: %@", loginurl);
	}
	loginURL = [[NSURL URLWithString:loginurl] retain];
	
	// get our data from Keychain
	[self retrieveKeychainData];
	
	[pool release];
}

// takes the command-line arguments and sets new prefs if necessary
- (void) storePrefs:(const char **)prefarray size:(int)size {
	NSStringEncoding enc = [NSString defaultCStringEncoding];
	// 1 + VERBOSE because of the extra slot -v takes up
	NSString *cmd = [[NSString alloc] initWithCString:prefarray[1 + VERBOSE] encoding:enc];
	if (![cmd hasPrefix:@"-storePrefs"]) {
		return;
	}
	
	NSMutableDictionary *prefs = [NSMutableDictionary dictionaryWithCapacity:(size - 2)];
	int i;
	for (i = 2 + VERBOSE; i < size; i++) {
		NSArray *pref = [[[NSString alloc] initWithCString:prefarray[i] encoding:enc]
				componentsSeparatedByString:@"="];
		[prefs setValue:[pref objectAtIndex:1] forKey:[pref objectAtIndex:0]];
	}
	
	// now extract the new prefs
	NSString *s;
	
	s = [prefs valueForKey:@"-ip_version"];
	if (s != nil) {
		[self setIpVersion:[NSNumber numberWithInteger:[s integerValue]]];
	}
	
	s = [prefs valueForKey:@"-interface"];
	if (s != nil) {
		[self setInterface:s];
	}
	
	s = [prefs valueForKey:@"-ssid"];
	if (s != nil) {
		[self setSSID:s];
	}
	
	s = [prefs valueForKey:@"-login_url"];
	if (s != nil) {
		[self setLoginUrl:s];
	}
	
	s = [prefs valueForKey:@"-post_data"];
	if (s != nil) {
		[self setPOSTData:s];
	}
}

- (const char *) retrieveUsername {
	CFDictionaryRef sessInfo = CGSessionCopyCurrentDictionary();
	if (sessInfo == NULL) {
		NSLog(@"Couldn't get username, quitting. (1)");
		exit(1);
	}
	CFStringRef usernameCF = CFDictionaryGetValue(sessInfo, kCGSessionUserNameKey);
	const char *username = [(NSString *)usernameCF UTF8String];
	CFRelease(usernameCF);
	
	return username;
}

// grabs the info we need from Keychain
- (void) retrieveKeychainData {
	const char *username = [self retrieveUsername];
	void *pwData = nil;
	UInt32 pwLength = 0;
	OSStatus status = SecKeychainFindGenericPassword(NULL, strlen(KEYCHAIN_SERVICE), KEYCHAIN_SERVICE
			, strlen(username), username, &pwLength, &pwData, NULL);
	if (status == noErr) {
		POSTData = [[NSString stringWithCString:pwData length:pwLength] retain];
		SecKeychainItemFreeContent(NULL, pwData);
		if (VERBOSE) NSLog(@"POST data: %@", POSTData);
	} else {
		if (VERBOSE) NSLog(@"Couldn't get data from Keychain");
		POSTData = @"";
	}
}

// IP Version Preference Accessors
- (NSNumber *) getIpVersion {
	return IPVersion;
}
- (void) setIpVersion:(NSNumber *)ipVer {
	if (VERBOSE) NSLog(@"Writing Setting: %s.  Value %@", PREFS_NETWORK_IPVER, ipVer);
	CFPreferencesSetAppValue(CFSTR(PREFS_NETWORK_IPVER), ipVer, appID);
	CFPreferencesAppSynchronize(appID);
	
	[IPVersion release];
	IPVersion = [ipVer retain];
}

// Network Interface Preference Accessors
- (NSString *) getInterface {
	return interface;
}
- (void) setInterface:(NSString *)iface {
	if (VERBOSE) NSLog(@"Writing Setting: %s.  Value %@", PREFS_NETWORK_INTERFACE, iface);
	CFPreferencesSetAppValue(CFSTR(PREFS_NETWORK_INTERFACE), iface, appID);
	CFPreferencesAppSynchronize(appID);
	
	[interface release];
	interface = [iface retain];
}

// SSID Preference Accessors
- (NSString *) getSSID {
	return SSID;
}
- (void) setSSID:(NSString *)ssid{
	if (VERBOSE) NSLog(@"Writing Setting: %s.  Value %@", PREFS_NETWORK_SSID, ssid);
	CFPreferencesSetAppValue(CFSTR(PREFS_NETWORK_SSID), ssid, appID);
	CFPreferencesAppSynchronize(appID);
	[SSID release];
	SSID = [ssid retain];
}

// loginUrl Preference Accessors
- (NSURL *) getLoginUrl {
	return loginURL;
}
- (void) setLoginUrl:(NSString*)url {
	if (VERBOSE) NSLog(@"Writing Setting: %s.  Value %@", PREFS_LOGINURL, url);
	CFPreferencesSetAppValue(CFSTR(PREFS_LOGINURL), url, appID);
	CFPreferencesAppSynchronize(appID);
	
	[loginURL release];
	loginURL = [[NSURL URLWithString:url] retain];
}

// POSTData accessors
- (NSString *) getPOSTData {
	return POSTData;
}
- (void) setPOSTData:(NSString *)data {
	const char *username = [self retrieveUsername];
	const char *pwData = [data UTF8String];
	UInt32 pwLength = [data length];
	SecKeychainItemRef item = nil;
	
	// find/modify or create the item
	OSStatus status = SecKeychainFindGenericPassword(NULL, strlen(KEYCHAIN_SERVICE), KEYCHAIN_SERVICE
			, strlen(username), username, NULL, NULL, &item);
	if (status == noErr) {
		status = SecKeychainItemModifyAttributesAndData(item, NULL, pwLength, pwData);
	} else if (status == errSecItemNotFound) {
		status = SecKeychainAddGenericPassword(NULL, strlen(KEYCHAIN_SERVICE), KEYCHAIN_SERVICE
				, strlen(username), username, pwLength, pwData, NULL);
	} 
	
	if (item) {
		CFRelease(item);
	}
	
	if (status == noErr) {
		if (VERBOSE) NSLog(@"Wrote POSTData to Keychain");
	
		[POSTData release];
		POSTData = data;
	} else {
		NSLog(@"Writing POSTData to Keychain failed: %s", GetMacOSStatusErrorString(status));
	}
}

- (void) dealloc {
	[IPVersion release];
	[interface release];
	[SSID release];
	[loginURL release];
	[POSTData release];
	
	[super dealloc];
}

@end
