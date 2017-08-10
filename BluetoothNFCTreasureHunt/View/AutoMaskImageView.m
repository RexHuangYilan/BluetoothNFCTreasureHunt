//
//  AutoMaskImageView.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/29.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "AutoMaskImageView.h"

@implementation AutoMaskImageView

-(void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    if (self.layer.mask) {
        self.layer.mask.frame = bounds;
    }
}

@end
