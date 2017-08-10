//
//  UIView+Border.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/27.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "UIView+Border.h"

@implementation UIView(Border)

-(void)border
{
    [self borderWithColor:[UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0]];
}

-(void)borderWithColor:(UIColor *)color
{
    self.layer.cornerRadius = 5; // 圓角的弧度
    self.layer.masksToBounds = YES;
    self.layer.borderColor = color.CGColor;
    self.layer.borderWidth = 1;
}

-(void)maskWithImage:(UIImage *)maskImage
{
    CALayer *mask = [CALayer layer];
    mask.contents = (id)[maskImage CGImage];
    mask.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.layer.mask = mask;
    self.layer.masksToBounds = YES;
}

@end
