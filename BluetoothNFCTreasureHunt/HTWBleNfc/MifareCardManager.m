//
//  MifareCardManager.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/15.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "MifareCardManager.h"

//Mifare Key type
#define  MIFARE_KEY_TYPE_A              ((Byte)0x0A)
#define  MIFARE_KEY_TYPE_B              ((Byte)0x0B)

#define  PHAL_MFC_CMD_READ      ((Byte)0x30)    /**< MIFARE Classic Read command byte */
#define  PHAL_MFC_CMD_WRITE     ((Byte)0xA0)    /**< MIFARE Classic Write command byte */

@implementation MifareCardManager

+(NSData *)key
{
    Byte keybytes[] = {(Byte) 0xff, (Byte) 0xff,(Byte) 0xff,(Byte) 0xff,(Byte) 0xff,(Byte) 0xff};
    NSData *keyData = [[NSData alloc] initWithBytes:keybytes length:6];
    return keyData;
}

+(NSData *)rfMifareAuthCmdData:(Byte)bBlockNo keyType:(Byte)bKeyType key:(NSData *)pKey uid:(NSData *)pUid {
    Byte returnByte[2 + 1 + 1 + 6 + 4];
    Byte *keyBytes = (Byte *)[pKey bytes];
    Byte *uidBytes = (Byte *)[pUid bytes];
    
    returnByte[0] = 0x00;
    returnByte[1] = [HTWBleNfcResponseObject byteWithCommand:HTWBleNfcCommandMifareKey];
    returnByte[2] = bBlockNo;
    returnByte[3] = bKeyType;
    memcpy(&returnByte[4], keyBytes, 6);
    memcpy(&returnByte[10], uidBytes, 4);
    
    return [NSData dataWithBytes:returnByte length:2 + 1 + 1 + 6 + 4];
}

+(NSData *)keyWithCard:(HTWBleNfcActuvatePiccObject *)card
{
    return [self rfMifareAuthCmdData:1 keyType:MIFARE_KEY_TYPE_A key:[self key] uid:card.uid];
}

+(NSData *)read
{
    Byte returnByte[4];
    
    returnByte[0] = 0x00;
    returnByte[1] = [HTWBleNfcResponseObject byteWithCommand:HTWBleNfcCommandMifareCom];
    returnByte[2] = PHAL_MFC_CMD_READ;
    returnByte[3] = 0x01;
    
    return [NSData dataWithBytes:returnByte length: 4];
}

+(NSData *)writeComData
{
    Byte returnByte[4];
    
    returnByte[0] = 0x00;
    returnByte[1] = [HTWBleNfcResponseObject byteWithCommand:HTWBleNfcCommandMifareCom];
    returnByte[2] = PHAL_MFC_CMD_WRITE;
    returnByte[3] = 0x01;
    
    return [NSData dataWithBytes:returnByte length: 4];
}

+(NSData *)writeWithData:(NSData *)data
{
    Byte returnByte[2];
    
    returnByte[0] = 0x00;
    returnByte[1] = [HTWBleNfcResponseObject byteWithCommand:HTWBleNfcCommandMifareCom];
    NSMutableData *temp = [NSMutableData dataWithBytes:returnByte length: 2];
    if (data.length > 16) {
        data = [data subdataWithRange:NSMakeRange(0, 16)];
    }else if (data.length < 16) {
        NSUInteger len = 16 - data.length;
        [temp increaseLengthBy:len];
    }
    [temp appendData:data];
    
    return temp;
}

@end
