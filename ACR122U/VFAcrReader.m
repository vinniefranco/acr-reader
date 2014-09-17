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

- (BOOL) open
{
    if ([self connect])
    {
        [NSThread detachNewThreadSelector: @selector(poll)
                                 toTarget: self
                               withObject: nil];
        return YES;
    }
    
    return NO;
}

- (void) close
{
    NSLog(@"Closing interface.");
    SCardDisconnect(hCard, SCARD_LEAVE_CARD);
    free(mszReaders);
    SCardReleaseContext(hContext);
}

- (NSString *) getTagUid
{
    return currentTagId;
}

- (NSString *) getCurrentReaderName
{
    return attachedReader;
}

- (NSString *) getLastError
{
    return lastError;
}

// *Private* -----------------------------------------------------------------

- (BOOL) connect
{
    rv = SCardEstablishContext(SCARD_SCOPE_SYSTEM, NULL, NULL, &hContext);
    
    if ([self signalWasSuccessful])
    {
        return [self listReaders];
    }
    
    return NO;
}

- (BOOL) listReaders
{
    rv = SCardListReaders(hContext, NULL, NULL, &dwReaders);
    
    if ([self signalWasSuccessful])
    {
        mszReaders = calloc(dwReaders, sizeof(char));
        return [self associateReader];
    }
    
    return NO;
}

- (BOOL) associateReader
{
    rv = SCardListReaders(hContext, NULL, mszReaders, &dwReaders);
    
    if ([self signalWasSuccessful])
    {
        NSLog(@"Reader connection: %s", mszReaders);
        attachedReader = [NSString stringWithFormat: @"%s", mszReaders];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(readerWasAttached:)])
        {
            [self.delegate readerWasAttached:attachedReader];
        }

        return YES;
    }
    
    return NO;
}

- (BOOL) signalWasSuccessful
{
    if (SCARD_S_SUCCESS == rv)
    {
        return YES;
    }
    
    [self executionError];
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
        usleep(THREAD_POLL_INTRV);
        rv = SCardGetStatusChange(hContext, INFINITE, &readerState, 1);
        if (rv != SCARD_S_SUCCESS)
        {
            [self executionError];
            [self close];
            break; // Exit thread. We are done here.
        }

        if ((readerState.dwEventState & SCARD_STATE_EMPTY) == SCARD_STATE_EMPTY && !isBlank)
        {
            NSLog(@"Card Absent");
            isRead = NO;
            isBlank = YES;
            if (self.delegate && [self.delegate respondsToSelector:@selector(readerIsEmpty)])
            {
                [self.delegate readerIsEmpty];
            }
        }
        else if ((readerState.dwEventState & SCARD_STATE_PRESENT) == SCARD_STATE_PRESENT)
        {
            isBlank = NO;
            [self readCard];
        }
    }
}

- (void) executionError
{
    lastError = [NSString stringWithFormat: @"%s", pcsc_stringify_error(rv)];
    if (self.delegate && [self.delegate respondsToSelector:@selector(readerReceivedError:)])
    {
        [self.delegate readerReceivedError:lastError];
    }
}

- (BOOL) connectCard
{
    rv = SCardConnect(hContext,
                      mszReaders,
                      SCARD_SHARE_SHARED,
                      SCARD_PROTOCOL_T0 | SCARD_PROTOCOL_T1,
                      &hCard,
                      &dwActiveProtocol);
    
    if ([self signalWasSuccessful]) {
        switch (dwActiveProtocol) {
            case SCARD_PROTOCOL_T0:
                pioSendPci = *SCARD_PCI_T0;
                break;
            case SCARD_PROTOCOL_T1:
                pioSendPci = *SCARD_PCI_T1;
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
    return [self signalWasSuccessful];
}

- (void) setCurrentUid
{
    NSMutableString *tagId = [NSMutableString string];
    for (unsigned int i=0; i < UID_LENGTH; i++) {
        [tagId appendFormat:@"%02x", pbRecvBuffer[i]];
    }
    
    currentTagId = [NSString stringWithString: tagId];
    NSLog(@"%@", currentTagId);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(readerReceivedNewRFIDTag:)])
    {
        [self.delegate readerReceivedNewRFIDTag:currentTagId];
    }
}

- (void) dealloc
{
    [self close];
    [super dealloc];
}

@end
