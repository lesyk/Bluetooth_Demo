#import "MainWindowController.h"
#import "ContactWindowController.h"

@class ContactWindowController;

@interface MainWindowController ()

@property (strong) ContactWindowController* contactWindow;

@end

@implementation MainWindowController

- (void)windowDidLoad {
    [super windowDidLoad];

    _contactWindow = [[ContactWindowController alloc] initWithWindowNibName:@"ContactWindowController"];
    _contactWindow.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:_contactWindow queue:nil];
}

- (IBAction)setUpConnection:(id)sender {
        [_contactWindow.window center];
        [_contactWindow.window orderFront:nil];
        [self.window orderOut:nil];
}

@end
