//
//  HTWBleNfcResponseObject.h
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/7.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HTWBleNfcResponseStatus) {
    HTWBleNfcResponseStatusIdle,
    HTWBleNfcResponseStatusStart,
    HTWBleNfcResponseStatusFollow,
    HTWBleNfcResponseStatusComplete
};

typedef NS_ENUM(NSUInteger, HTWBleNfcCommand) {
    HTWBleNfcCommandNone,
    HTWBleNfcCommandVersion,    //取得版本
    HTWBleNfcCommandElectricity,    //取電池電量
    HTWBleNfcCommandActuvate_picc,  //尋找卡片
    HTWBleNfcCommandOff,  //結束天線
    HTWBleNfcCommandMifareKey,  //Mifare KEY驗證
    HTWBleNfcCommandMifareCom,  //Mifare卡指令通道
};


@interface HTWBleNfcResponseObject : NSObject

@property(readonly) HTWBleNfcResponseStatus status;
@property(readonly) HTWBleNfcCommand com;
@property(readonly) BOOL comRunStatus;
@property(nonatomic,strong) NSMutableData *data;

-(BOOL)analysisWithData:(NSData *)rcvData;

+(Byte)byteWithCommand:(HTWBleNfcCommand)command;
+(NSData *)dataWithCommand:(HTWBleNfcCommand)command;
+(HTWBleNfcCommand)commandWithByte:(Byte)byte;
+(HTWBleNfcCommand)commandWithData:(NSData *)data;

@end
