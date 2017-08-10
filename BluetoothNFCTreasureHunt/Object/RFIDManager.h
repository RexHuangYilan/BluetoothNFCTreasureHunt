//
//  RFIDManager.h
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/27.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFIDInfoObject.h"

@interface RFIDManager : NSObject

@property(class,readonly) NSArray<RFIDInfoObject *> *RFIDinfoObjects;
@property(class,readonly) NSString *answer;

/// 新增
+(void)appendData:(RFIDInfoObject *)data;
/// 插入
+(void)insertData:(RFIDInfoObject *)data atIndex:(NSInteger)atIndex;
/// 修改
+(void)updateData:(RFIDInfoObject *)data;
/// 刪除
+(void)removeRfid:(NSString *)rfid;
/// 查詢
+(RFIDInfoObject *)objectWithRfid:(NSString *)rfid;
@end
