//
//  AppDelegate.h
//  BLEForMac
//
//  Created by Jewel on 16/9/9.
//  Copyright © 2016年 Jewel. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainWindowController.h"
@class MainWindowController;
@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (strong) MainWindowController *mainWindow;

@end

