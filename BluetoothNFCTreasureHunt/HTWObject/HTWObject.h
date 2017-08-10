//
//  HTWObject.h
//  HTWObjectExmaple
//
//  Created by Rex on 2015/10/1.
//  Copyright (c) 2015年 Rex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTWObject : NSObject<NSCopying>

//建立物件陣列
+ (NSArray *)objectFromArray:(NSArray *)array;

//建立物件
+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary;

//初始化
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

//轉換成Dictionary
-(NSDictionary *)convertToDictionary;

//轉換中會被呼叫，覆寫可強制轉換為其它內容
-(id)convertWithValue:(id)value propertyName:(NSString *)propertyName;

@end
