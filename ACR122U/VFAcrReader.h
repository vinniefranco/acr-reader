//
//  VFAcrReader.h
//  ACR122U
//
//  Created by Vincent Franco on 9/16/14.
//  Copyright (c) 2014 Vincent Franco. All rights reserved.
//

#include <PCSC/winscard.h>
#import <Foundation/Foundation.h>

#define GET_UID { 0xFF, 0xCA, 0x00, 0x00, 0x00 }
#define LED_FLASH { 0xFF, 0x00, 0x40, 0xCF, 0x04, 0x01, 0x01, 0x02, 0x01 }
#define UID_LENGTH 7
#define THREAD_POLL_INTRV 56000

@class VFAcrReader;

@protocol VFAcrDelegate <NSObject>

@required
- (void) readerReceivedNewRFIDTag:(NSString *)tagUid;
- (void) readerReceivedError:(NSString *)error;
- (void) readerWasAttached:(NSString *) readerName;
- (void) readerIsEmpty;

@end

@interface VFAcrReader : NSObject {
    @private
    BOOL isRead;
    BOOL isBlank;
    NSString *currentTagId;
    NSString *lastError;
    NSString *attachedReader;
    uint32_t rv;
    SCARDCONTEXT hContext;
    char *mszReaders;
    SCARDHANDLE hCard;
    uint32_t dwReaders, dwActiveProtocol, dwRecvLength;
    SCARD_IO_REQUEST pioSendPci;
    uint8_t pbRecvBuffer[258];
}

@property (nonatomic, assign) id delegate;

- (BOOL) open;
- (void) close;
- (NSString *) getTagUid;
- (NSString *) getCurrentReaderName;
- (NSString *) getLastError;
@end
