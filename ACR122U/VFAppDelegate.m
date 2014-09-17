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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    reader = [[VFAcrReader alloc] init];
    reader.delegate = self;
    [reader open];
}

- (void) readerWasAttached:(NSString *)readerName {}
- (void) readerIsEmpty {}
- (void) readerReceivedNewRFIDTag:(NSString *)tagUid {}
- (void) readerReceivedError:(NSString *)error
{
    NSLog(@"From delegate: %@", error);
}

@end
