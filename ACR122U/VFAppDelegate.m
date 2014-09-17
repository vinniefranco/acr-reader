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
@synthesize segControl;
@synthesize keyboard;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    reader = [[VFAcrReader alloc] init];
    keyboard = [[VFKeyboardEmulator alloc] init];
    
    [[segControl cell] setTag:0 forSegment:0];
    [[segControl cell] setTag:1 forSegment:1];
    [segControl setTarget:self];
    [segControl setAction:@selector(segControlClicked:)];
    
    reader.delegate = self;
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

- (void) segControlClicked: (id) sender
{
    int clickedSegment = [sender selectedSegment];
    int clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];
    
    [status setStringValue:@""];
    [data setStringValue:@""];
    NSLog(@"%d", clickedSegmentTag);
    (clickedSegmentTag == 0) ? [reader open] : [reader close];
}

@end
