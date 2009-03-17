//
//  WifiMonitor.h
//  WifiMonitor
//
//  Copyright 2008.
//


int main (int argc, const char *argv[]);
void handleSIGHUP(int sig);
void updateCallBack(SCDynamicStoreRef store, CFArrayRef changedKeys, void *info);


int VERBOSE = 0;
int prefsNeedReload = 0;

@interface WifiMonitor : NSObject {
	WifiPreferences *prefs;
	SCDynamicStoreRef store;
}

- (id) init;
- (void) reload;
- (void) execResponse;
- (void) dealloc;

@end
