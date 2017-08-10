//
//  GuessNumberViewController.h
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/6/1.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GuessNumberViewControllerDelegate <NSObject>

//解答成功
-(void)isSuccess;

@end

@interface GuessNumberViewController : UIViewController

+(instancetype)viewController;
@property(nonatomic,weak) id<GuessNumberViewControllerDelegate> delegate;


@end
