//
//  VFAppDelegate.m
//  ACR122U
//
//  Created by Vincent Franco on 9/16/14.
//  Copyright (c) 2014 Vincent Franco. All rights reserved.
//

#import "VFAppDelegate.h"
#import "VFAcrReader.h"

@implementation VFAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    VFAcrReader *reader = [[VFAcrReader alloc] init];
    [reader open];
}

@end
