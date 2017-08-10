//
//  RFIDTableViewCell.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/27.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "RFIDTableViewCell.h"

@implementation RFIDTableViewCell

-(void)setObject:(RFIDInfoObject *)object
{
    _object = object;
    self.nameLabel.text = object.name;
    self.rfidLabel.text = [NSString stringWithFormat:@"<%@>",object.rfid];
    self.guessNumberLabel.text = [NSString stringWithFormat:@"%ld",(long)object.guessNumber];
    self.descriptionLabel.text = object.descriptionText;
    self.promptImageView.image = object.promptImage;
    self.maskImageView.image = object.maskImage;
}

@end
