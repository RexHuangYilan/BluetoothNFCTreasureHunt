//
//  UIView+Animation.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/6/4.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "UIView+Animation.h"

@implementation UIView(Animation)

-(void)startAnimation
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 20;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 100000;
    
    [self.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

-(void)endAnimation
{
    [self.layer removeAllAnimations];
}

@end
