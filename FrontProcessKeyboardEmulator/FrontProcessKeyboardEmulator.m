//
//  FrontProcessKeyboardEmulator.m
//  FrontProcessKeyboardEmulator
//
//  Created by Vincent Franco on 9/17/14.
//  Copyright (c) 2014 Vincent Franco. All rights reserved.
//

#import "FrontProcessKeyboardEmulator.h"

@implementation FrontProcessKeyboardEmulator

- (void) write: (NSString *)str
{
    unsigned int strLen = [str length];
    ProcessSerialNumber psn;
    GetFrontProcess(&psn);
    
    for(unsigned int i = 0; i < strLen; i++) {
        CGEventRef e = CGEventCreateKeyboardEvent(nil, 0, YES);
        UniChar c = [str characterAtIndex: i];
        CGEventKeyboardSetUnicodeString(e, 1, &c);
        CGEventPostToPSN(&psn,e);
        CFRelease(e);
    }
    
    CGEventRef e = CGEventCreateKeyboardEvent(nil, (CGKeyCode)36, YES);
    CGEventPostToPSN(&psn,e);
    CFRelease(e);
}

@end
