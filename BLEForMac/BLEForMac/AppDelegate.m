#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    _mainWindow = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
    [[_mainWindow window]center];
    [_mainWindow.window orderFront:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
