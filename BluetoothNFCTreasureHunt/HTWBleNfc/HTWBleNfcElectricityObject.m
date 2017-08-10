//
//  HTWBleNfcElectricityObject.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/7.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "HTWBleNfcElectricityObject.h"

@implementation HTWBleNfcElectricityObject

-(void)setData:(NSMutableData *)data
{
    [super setData:data];
    Byte *rcvBytes = (Byte *)[self.data bytes];
    float btValue = (float)(((unsigned int)rcvBytes[0] << 8) | (unsigned int)rcvBytes[1]) / 100.0;
    _electricity = btValue;
}

@end
