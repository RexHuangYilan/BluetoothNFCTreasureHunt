//
//  HTWBleNfcVersionObject.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/7.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "HTWBleNfcVersionObject.h"

@implementation HTWBleNfcVersionObject

-(void)setData:(NSMutableData *)data
{
    [super setData:data];
    Byte *rcvBytes = (Byte *)[self.data bytes];
    _version = (NSInteger)(rcvBytes[0]);
}

@end
