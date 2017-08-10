//
//  RFIDInfoObject.h
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/27.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "HTWObject.h"
#import <UIKit/UIKit.h>

@interface RFIDInfoObject : HTWObject
/// RFID
@property(nonatomic,strong) NSString *rfid;
/// 名稱
@property(nonatomic,strong) NSString *name;
/// 迷底數字
@property(nonatomic) NSInteger guessNumber;
/// 說明
@property(nonatomic,strong) NSString *descriptionText;
/// 提示圖
@property(nonatomic,strong) UIImage *promptImage;
/// 遮罩圖
@property(nonatomic,strong) UIImage *maskImage;

/// 是否不秀遮罩
@property(nonatomic) BOOL isNotShowMask;
/// 是否秀迷底
@property(nonatomic) BOOL isShowGuess;

@end
