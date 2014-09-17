//
//  VFAppDelegate.m
//  ACR122U
//
//  Created by Vincent Franco on 9/16/14.
//  Copyright (c) 2014 Vincent Franco. All rights reserved.
//

#import "VFAppDelegate.h"

@implementation VFAppDelegate

@synthesize reader;
@synthesize data;
@synthesize status;
@synthesize keyboard;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    reader = [[VFAcrReader alloc] init];
    keyboard = [[VFKeyboardEmulator alloc] init];
    reader.delegate = self;
    
    [reader open];
}

- (void) readerWasAttached:(NSString *)readerName
{
    [status setStringValue: [NSString stringWithFormat: @"%@ connected",readerName]];
}

- (void) readerIsEmpty
{
    [status setStringValue:@"Reader is empty..."];
}

- (void) readerReceivedNewRFIDTag:(NSString *)tagUid
{
    [data setStringValue:tagUid];
    [keyboard write:tagUid];
}
- (void) readerReceivedError:(NSString *)error
{
    [data setStringValue:@"..."];
    [status setStringValue: [NSString stringWithFormat:@"Error: %@", error]];
    NSLog(@"Error: %@", error);
}

@end
