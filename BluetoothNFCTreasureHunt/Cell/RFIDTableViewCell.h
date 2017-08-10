//
//  RFIDTableViewCell.h
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/27.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFIDInfoObject.h"

@interface RFIDTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *promptImageView;  //提示圖
@property (weak, nonatomic) IBOutlet UIImageView *maskImageView;    //遮罩圖
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;            //名稱
@property (weak, nonatomic) IBOutlet UILabel *rfidLabel;            //RFID
@property (weak, nonatomic) IBOutlet UILabel *guessNumberLabel;     //迷底數字
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;     //說明
@property (strong, nonatomic) RFIDInfoObject *object;

@end
