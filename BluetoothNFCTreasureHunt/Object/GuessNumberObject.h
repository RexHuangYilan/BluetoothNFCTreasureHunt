//
//  GuessNumberObject.h
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/6/3.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* const GuessNumberErrorDomain;

typedef NS_ENUM(NSUInteger, GuessNumberError) {
    GuessNumberErrorNoAnswer,
    GuessNumberErrorNoReply,
    GuessNumberErrorReplyLengthNotEqualAnswerLength,
};

@interface GuessNumberObject : NSObject

/// 正解
@property (nonatomic,strong) NSString *answer;
/// 回答
@property (nonatomic,strong) NSString *reply;
/// 完全正確的數量
@property (readonly) NSInteger a;
/// 部份正確的數量
@property (readonly) NSInteger b;
/// 錯誤訊息
@property (readonly) NSError *error;
/// 是否完全正確
@property (readonly) BOOL isEqual;

@end
