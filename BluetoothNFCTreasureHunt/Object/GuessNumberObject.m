//
//  GuessNumberObject.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/6/3.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "GuessNumberObject.h"

NSString* const GuessNumberErrorDomain = @"com.BLE.NFC.GuessNumber";

@interface GuessNumberObject()

/// 完全正確的數量
@property (nonatomic) NSInteger a;
/// 部份正確的數量
@property (nonatomic) NSInteger b;
/// 錯誤訊息
@property (nonatomic,strong) NSError *error;

@end

@implementation GuessNumberObject

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self checkReplyLength];
    }
    return self;
}

#pragma mark - 檢查相關

-(BOOL)checkReplyLength
{
    BOOL isEqual = NO;
    if (self.answer.length == 0) {
        self.error = [NSError errorWithDomain:GuessNumberErrorDomain code:GuessNumberErrorNoAnswer userInfo:@{@"message":@"沒有設定正解"}];
    }else if (self.reply.length == 0) {
        self.error = [NSError errorWithDomain:GuessNumberErrorDomain code:GuessNumberErrorNoReply userInfo:@{@"message":@"沒有設定回答"}];
    }else if (self.answer.length != self.reply.length) {
        self.error = [NSError errorWithDomain:GuessNumberErrorDomain code:GuessNumberErrorReplyLengthNotEqualAnswerLength userInfo:@{@"message":@"回答的長度不等於正解長度"}];
    }else{
        self.error = nil;
        isEqual = YES;
    }
    
    return isEqual;
}

#pragma mark - 設定相關

-(void)setError:(NSError *)error
{
    _error = error;
    if (error) {
        self.a = 0;
        self.b = 0;
    }
}

-(void)setAnswer:(NSString *)answer
{
    _answer = answer;
    [self guessNumber];
}

-(void)setReply:(NSString *)reply
{
    _reply = reply;
    [self guessNumber];
}

#pragma mark - 取得相關

/// 是否完全正確
-(BOOL)isEqual
{
    return [self.answer isEqualToString:self.reply];
}

#pragma mark - 猜數字相關

-(void)guessNumber
{
    if (![self checkReplyLength]) {
        return;
    }
    NSInteger a = 0;
    NSInteger b = 0;
    NSMutableString *bArray = [NSMutableString string];  //不是a的答案
    NSMutableString *tempArray = [NSMutableString string];     //不是a的回答
    
    const char *answers = [self.answer UTF8String];
    const char *replys = [self.reply UTF8String];
    
    /// 先找a
    for(int i=0;i<strlen(answers);i++){
        if (answers[i] == replys[i]) {
            a++;
        }else{
            [tempArray appendFormat:@"%c", replys[i]];
            [bArray appendFormat:@"%c", answers[i]];
        }
    }
    /// 先找b
    answers = [bArray UTF8String];
    replys = [tempArray UTF8String];
    for(int i=0;i<strlen(answers);i++){
        NSRange range = [tempArray rangeOfString:[NSString stringWithFormat:@"%c",answers[i]]];
        if (range.location != NSNotFound) {
            b++;
            [tempArray deleteCharactersInRange:range];
        }
    }
    self.a = a;
    self.b = b;
}

@end
