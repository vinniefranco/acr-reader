//
//  VFAppDelegate.h
//  ACR122U
//
//  Created by Vincent Franco on 9/16/14.
//  Copyright (c) 2014 Vincent Franco. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VFAcrReader.h"
#import "VFKeyboardEmulator.h"

@interface VFAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) VFAcrReader *reader;

@end
