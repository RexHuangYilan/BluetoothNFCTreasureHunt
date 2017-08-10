//
//  BorderButton.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/6/1.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "BorderButton.h"
#import "UIView+Border.h"

@implementation BorderButton

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self borderWithColor:[self titleColorForState:UIControlStateNormal]];
}

-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.alpha = highlighted?.5:1;
}

@end
