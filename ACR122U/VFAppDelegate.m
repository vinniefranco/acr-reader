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
    reader = [[ACR122UReader alloc] init];
    keyboard = [[FrontProcessKeyboardEmulator alloc] init];
    
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
    [data setStringValue:@""];
    [status setStringValue:@"Reader is empty..."];
}

- (void) readerReceivedNewRFIDTag:(NSString *)tagUid
{
    [status setStringValue:@"Tag present"];
    [data setStringValue:tagUid];
    [keyboard write:tagUid];
}
- (void) readerReceivedError:(NSError *)error
{
    [data setStringValue:@"..."];
    NSString *domainError = error.localizedDescription;
    [status setStringValue: [NSString stringWithFormat:@"%@", domainError]];
}

- (void) readerHasClosed
{
    [segControl setSelectedSegment:1];
}

- (void) segControlClicked: (id) sender
{
    int clickedSegment = [sender selectedSegment];
    int clickedSegmentTag = [[sender cell] tagForSegment:clickedSegment];
    
    if (clickedSegmentTag == 0)
    {
        [reader open];
    }
    else
    {
        [reader close];
        [status setStringValue:@""];
    }
}

@end