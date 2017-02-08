//
//  AppDelegate.m
//  BLEForMac
//
//  Created by Jewel on 16/9/9.
//  Copyright © 2016年 Jewel. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    _mainWindow = [[MainWindowController alloc] initWithWindowNibName:@"MainWindowController"];
//    使屏幕位于电脑中央
    [[_mainWindow window]center];
//    前置显示窗口
    [_mainWindow.window orderFront:nil];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
