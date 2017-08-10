//
//  MifareCardManager.h
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/15.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTWBleNfcActuvatePiccObject.h"

@interface MifareCardManager : NSObject

+(NSData *)keyWithCard:(HTWBleNfcActuvatePiccObject *)card;
//取資料
+(NSData *)read;

+(NSData *)writeComData;
+(NSData *)writeWithData:(NSData *)data;
@end
