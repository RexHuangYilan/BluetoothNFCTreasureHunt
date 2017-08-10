//
//  HTWBleNfcController.h
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/6.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTWBleNfcResponseObject.h"

extern NSErrorDomain ble_nfc_error_domian;

typedef NS_ENUM(NSUInteger, MifareComType) {
    MifareComTypeNone,
    MifareComTypeRead,
    MifareComTypeWriteReady,
    MifareComTypeWrite,
};

typedef NS_ENUM(NSUInteger, HTWBleNfcCommandError) {
    HTWBleNfcCommandErrorVersion,
    HTWBleNfcCommandErrorElectricity,
    HTWBleNfcCommandErrorActuvate_picc,
    HTWBleNfcCommandErrorOther,
};

@protocol HTWBleNfcControllerDelegate <NSObject>


@optional
-(void)keyConnect:(BOOL)connect;
-(void)keyClick;
-(void)bleNFCready;
-(void)bleNFCerror:(NSError *)error;
-(void)bleNFCResponse:(HTWBleNfcResponseObject *)response;
@end

@interface HTWBleNfcController : NSObject

@property (nonatomic,weak) id<HTWBleNfcControllerDelegate>delegate;
@property (readonly) NSInteger version;
@property (readonly) float electricity;
@property (readonly) BOOL isBleConnect;

+ (instancetype)sharedInstance;

-(void)startScan;
-(void)stopScan;
//刪除key
-(void)removeKeyPeripheral;

//發送訊息
-(Boolean)writeData:(NSData *)writeData;
//查詢卡片
-(void)searchCard;
//關閉天線
-(void)powerOff;

@end
