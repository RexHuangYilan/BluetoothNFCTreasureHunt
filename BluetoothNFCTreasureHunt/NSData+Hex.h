//
//  NSData+Hex.h
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/19.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSStringHexToBytes)
- (NSData *)hexToBytes ;
@end

@interface NSData (NSDataToString)
- (NSString *)convertDataToHexStr;
@end
