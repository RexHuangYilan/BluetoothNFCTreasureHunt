//
//  RFIDEditViewController.h
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/27.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RFIDManager.h"

@interface RFIDEditViewController : UIViewController
@property (nonatomic ,strong) RFIDInfoObject *infoObject;

+(instancetype)viewControllerWithRFID:(RFIDInfoObject *)rfid;

@end
