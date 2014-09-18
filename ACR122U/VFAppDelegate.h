//
//  VFAppDelegate.h
//  ACR122U
//
//  Created by Vincent Franco on 9/16/14.
//  Copyright (c) 2014 Vincent Franco. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ACR122UReader.h"
#import "FrontProcessKeyboardEmulator.h"

@interface VFAppDelegate : NSObject <NSApplicationDelegate, VFAcrDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSTextField *data;
@property (assign) IBOutlet NSTextField *status;
@property (assign) IBOutlet NSSegmentedControl *segControl;
@property (assign) ACR122UReader *reader;
@property (assign) FrontProcessKeyboardEmulator *keyboard;

@end
