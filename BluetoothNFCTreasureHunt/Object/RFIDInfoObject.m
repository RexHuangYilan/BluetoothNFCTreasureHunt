//
//  RFIDInfoObject.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/27.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "RFIDInfoObject.h"

@implementation RFIDInfoObject

-(id)convertWithValue:(id)value propertyName:(NSString *)propertyName
{
    if ([propertyName isEqualToString:@"promptImage"] || [propertyName isEqualToString:@"maskImage"]) {
        UIImage *image = value;
        NSData *data = UIImagePNGRepresentation(image);
        return data;
    }
    return value;
}

@end
