//
//  RFIDManager.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/27.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "RFIDManager.h"

#define RFIDINFO @"RFIDinfo"

NSArray<RFIDInfoObject *> *rfidInfoObjects;

@implementation RFIDManager

+(NSArray *)getValue
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault arrayForKey:RFIDINFO];
}

+(void)saveValue:(NSArray *)value
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:value forKey:RFIDINFO];
    [userDefault synchronize];
    [self setRFIDinfoWithArray:value];
}

+(void)appendData:(RFIDInfoObject *)data
{
    if (data.rfid.length == 0) {
        return;
    }
    NSDictionary *temp = [data convertToDictionary];
    NSMutableArray *rfidInfos = [[self getValue] mutableCopy];
    [rfidInfos addObject:temp];
    [self saveValue:rfidInfos];
}

+(void)insertData:(RFIDInfoObject *)data atIndex:(NSInteger)atIndex
{
    if (data.rfid.length == 0) {
        return;
    }
    NSDictionary *temp = [data convertToDictionary];
    NSMutableArray *rfidInfos = [[self getValue] mutableCopy];
    [rfidInfos insertObject:temp atIndex:atIndex];
    [self saveValue:rfidInfos];
}

+(void)updateData:(RFIDInfoObject *)data
{
    if (data.rfid.length == 0) {
        return;
    }
    NSInteger index = [self indexWithRfid:data.rfid];
    if (index == NSNotFound) {
        [self appendData:data];
        return;
    }
    NSMutableArray *rfidInfos = [[self getValue] mutableCopy];
    
    if (index >= rfidInfos.count) {
        return;
    }
    NSDictionary *temp = [data convertToDictionary];
    
    [rfidInfos replaceObjectAtIndex:index withObject:temp];
    [self saveValue:rfidInfos];
}

+(void)removeRfid:(NSString *)rfid
{
    NSInteger index = [self indexWithRfid:rfid];
    if (index == NSNotFound) {
        return;
    }
    NSMutableArray *rfidInfos = [[self getValue] mutableCopy];
    [rfidInfos removeObjectAtIndex:index];
    [self saveValue:rfidInfos];
}

+(RFIDInfoObject *)objectWithRfid:(NSString *)rfid
{
    NSInteger index = [self indexWithRfid:rfid];
    
    return (index == NSNotFound || index >= self.RFIDinfoObjects.count)?nil:self.RFIDinfoObjects[index];
}

+(NSInteger)indexWithRfid:(NSString *)rfid
{
    if (rfid.length == 0) {
        return NSNotFound;
    }
    BOOL isFind = NO;
    NSInteger index = 0;
    for (RFIDInfoObject * obj in self.RFIDinfoObjects) {
        if ([obj.rfid isEqualToString:rfid]) {
            isFind = YES;
            break;
        }
        index++;
    }
    return isFind?index:NSNotFound;
}

+(void)reloadRFIDinfo
{
    NSArray *rfidInfos = [self getValue];
    if (!rfidInfos) {
        rfidInfos = [NSArray array];
        [self saveValue:rfidInfos];
    }else{
        [self setRFIDinfoWithArray:rfidInfos];
    }
}

+(void)setRFIDinfoWithArray:(NSArray *)array
{
    rfidInfoObjects = [RFIDInfoObject objectFromArray:array];
}

+(NSArray<RFIDInfoObject *> *)RFIDinfoObjects
{
    if (!rfidInfoObjects) {
        [self reloadRFIDinfo];
    }
    return rfidInfoObjects;
}

+(NSString *)answer
{
    NSMutableString *answer = [NSMutableString string];
    for (RFIDInfoObject *obj in [RFIDManager RFIDinfoObjects]) {
        [answer appendFormat:@"%ld",(long)obj.guessNumber];
    }
    return answer;
}

@end
