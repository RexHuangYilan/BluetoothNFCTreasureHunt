//
//  HTWBleNfcActuvatePiccObject.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/12.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "HTWBleNfcActuvatePiccObject.h"

@implementation HTWBleNfcActuvatePiccObject

-(void)setData:(NSMutableData *)data
{
    [super setData:data];
    Byte *rcvBytes = (Byte *)[self.data bytes];
    if (self.comRunStatus) {
        self.type = rcvBytes[0];
        if (self.type == DKMifare_Type) {
            self.uid = [data subdataWithRange:NSMakeRange(1, 4)];
            self.atr = [data subdataWithRange:NSMakeRange(5, data.length - 5)];
        }
    }
}

@end
