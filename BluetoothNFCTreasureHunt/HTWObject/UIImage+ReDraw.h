//
//  UIImage+ReDraw.h
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/27.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage(ReDraw)
+ (UIImage *)drawImage:(UIImage *)image width:(CGFloat)width;

- (UIImage *)imageByApplyingAlpha:(CGFloat) alpha;
@end
