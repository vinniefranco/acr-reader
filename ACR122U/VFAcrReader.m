//
//  VFAcrReader.m
//  ACR122U
//
//  Created by Vincent Franco on 9/16/14.
//  Copyright (c) 2014 Vincent Franco. All rights reserved.
//

#import "VFAcrReader.h"

@implementation VFAcrReader

- (id) init
{
    self = [super init];
    
    if (self)
    {
        isRead = NO;
    }
    
    return self;
}

- (BOOL) connect
{
    rv = SCardEstablishContext(SCARD_SCOPE_SYSTEM, NULL, NULL, &hContext);
    
    if ([self successful:@"SCardEstablishContext"])
    {
        return [self listReaders];
    }
    
    return NO;
}

- (BOOL) listReaders
{
    rv = SCardListReaders(hContext, NULL, NULL, &dwReaders);
    
    if ([self successful:@"SCardListReaders"])
    {
        mszReaders = calloc(dwReaders, sizeof(char));
        return [self associateReader];
    }
    
    return NO;
}

- (BOOL) associateReader
{
    rv = SCardListReaders(hContext, NULL, mszReaders, &dwReaders);
    
    if ([self successful:@"SCardListReaders"])
    {
        NSLog(@"Reader connection: %s", mszReaders);
        attachedReader = [NSString stringWithFormat: @"%s", mszReaders];
        return YES;
    }
    
    return NO;
}

- (BOOL) successful: (NSString *)context
{
    if (SCARD_S_SUCCESS == rv)
    {
        NSLog(@"%@ successful", context);
        return YES;
    }
    
    lastError = [NSString stringWithFormat: @"%@: %s", context, pcsc_stringify_error(rv)];
    return NO;
}


- (void) poll
{
    NSLog(@"In thread");
    
    SCARD_READERSTATE_A readerState;
    readerState.szReader = mszReaders;
    readerState.dwCurrentState = SCARD_STATE_UNAWARE;
    readerState.dwEventState = SCARD_STATE_UNKNOWN;

    for (;;)
    {

        usleep(56000);
        rv = SCardGetStatusChange(hContext, INFINITE, &readerState, 1);

        if ((readerState.dwEventState & SCARD_STATE_EMPTY) == SCARD_STATE_EMPTY && !isBlank)
        {
            NSLog(@"Card Absent");
            isRead = NO;
            isBlank = YES;
        }
        else if ((readerState.dwEventState & SCARD_STATE_PRESENT) == SCARD_STATE_PRESENT)
        {
            isBlank = NO;
            [self readCard];
        }
        
    }
}

- (BOOL) connectCard
{
    rv = SCardConnect(hContext, mszReaders, SCARD_SHARE_SHARED, SCARD_PROTOCOL_T0 | SCARD_PROTOCOL_T1, &hCard, &dwActiveProtocol);
    
    if ([self successful:@"SCardConnect"]) {
        switch (dwActiveProtocol) {
            case SCARD_PROTOCOL_T0:
                pioSendPci = * SCARD_PCI_T0;
                break;
            case SCARD_PROTOCOL_T1:
                pioSendPci = * SCARD_PCI_T1;
                break;
        }
        
        dwRecvLength = sizeof(pbRecvBuffer);
        return YES;
    }
    
    return NO;
}

- (void) readCard
{
    if (isRead) {
        return;
    }
    
    NSLog(@"Reading card.");
    if ([self connectCard] && [self readTagUid]) {
        isRead = YES;
    }
}

- (BOOL) readTagUid
{
    uint8_t tagUidCmd[] = GET_UID;
    uint8_t flashLed[] = LED_FLASH;

    if ([self sendCmd: tagUidCmd cmdLength: sizeof(tagUidCmd)]) {
        [self setCurrentUid];
        [self sendCmd:flashLed cmdLength:sizeof(flashLed)];
        
        return YES;
    }
    
    return NO;
}

- (BOOL) sendCmd: (const unsigned char *) cmd cmdLength: (uint8_t) len
{
    rv = SCardTransmit(hCard, &pioSendPci, cmd, len, NULL, pbRecvBuffer, &dwRecvLength);
    return [self successful: @"SendCommand"];
}

- (void) setCurrentUid
{
    NSString *tagId = @"";
    for (unsigned int i=0; i < UID_LENGTH; i++) {
        tagId = [tagId stringByAppendingString:[NSString stringWithFormat:@"%02x", pbRecvBuffer[i]]];
    }
    NSLog(@"%@", tagId);
    currentTagId = tagId;
}

- (BOOL) open
{
    if ([self connect])
    {
        [NSThread detachNewThreadSelector: @selector(poll)
                                 toTarget: self
                               withObject: nil];
        return YES;
    }
    
    NSLog(lastError);
    return NO;
}

- (void) dealloc
{

    free(mszReaders);
    rv = SCardReleaseContext(hContext);
    [self successful:@"SCardReleaseContext"];
    [super dealloc];
}
@end
