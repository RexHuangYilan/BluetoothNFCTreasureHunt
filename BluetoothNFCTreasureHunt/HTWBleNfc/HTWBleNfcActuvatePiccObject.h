//
//  HTWBleNfcActuvatePiccObject.h
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/12.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "HTWBleNfcResponseObject.h"

typedef NS_ENUM(NSUInteger, DKCardType) {
    DKCardTypeDefault = 0,
    DKIso14443A_CPUType = 1,
    DKIso14443B_CPUType = 2,
    DKFeliCa_Type = 3,
    DKMifare_Type = 4,
    DKIso15693_Type = 5,
    DKUltralight_type = 6,
    DKDESFire_type = 7
};

@interface HTWBleNfcActuvatePiccObject : HTWBleNfcResponseObject

@property(nonatomic) DKCardType type;
@property (nonatomic,strong) NSData *uid;
@property (nonatomic,strong) NSData *atr;

@end
