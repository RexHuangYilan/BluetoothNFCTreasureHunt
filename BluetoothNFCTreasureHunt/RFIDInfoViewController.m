//
//  RFIDInfoViewController.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/29.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "RFIDInfoViewController.h"
#import "HTWBleNfcController.h"
#import "AutoMaskImageView.h"
#import "UIImage+ReDraw.h"

@interface RFIDInfoViewController ()<HTWBleNfcControllerDelegate>
@property (readonly) HTWBleNfcController *blenfc;
@property (weak, nonatomic) IBOutlet AutoMaskImageView *promptImageView;  //提示圖
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;     //說明
@property (weak, nonatomic) IBOutlet UIImageView *treasureMapImageView;
@property (weak, nonatomic) IBOutlet UIImageView *angelImageView;
@property (weak, nonatomic) IBOutlet UILabel *guessLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *guessX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *guessY;


@end

@implementation RFIDInfoViewController

+(instancetype)viewControllerWithRFID:(RFIDInfoObject *)rfid
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RFIDInfoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"rfidInfoVC"];
    vc.infoObject = rfid;
    return vc;
}

#pragma mark - 生命週期相關

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = appDelegate.window;
    UIViewController *vc = window.rootViewController;
    CGFloat width = vc.view.frame.size.width;
    CGAffineTransform transform = CGAffineTransformMakeScale(width/375.0,width/375.0);
    self.view.transform = transform;
    [self.blenfc startScan];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.blenfc.delegate = self;
    [self synchronizeIntoToInput];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self randomXY];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.blenfc stopScan];
    [self.blenfc removeKeyPeripheral];
}

-(void)showGuess:(BOOL)show
{
    self.guessLabel.alpha = show?1:0.2;
    self.guessLabel.backgroundColor = show?[UIColor whiteColor]:[UIColor clearColor];
}

-(void)randomXY
{
    NSInteger maxX = self.promptImageView.frame.size.width - self.guessLabel.frame.size.width;
    NSInteger maxY = self.promptImageView.frame.size.height - self.guessLabel.frame.size.height;
    int x = arc4random() % maxX;
    int y = arc4random() % maxY;
    
    self.guessX.constant = x;
    self.guessY.constant = y;
}

#pragma mark - 取得相關


-(HTWBleNfcController *)blenfc
{
    return [HTWBleNfcController sharedInstance];
}

#pragma mark - 按鈕相關

- (IBAction)doClosrButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark - 同步相關

-(void)synchronizeIntoToInput
{
    self.title = self.infoObject.name;
    self.descriptionLabel.text = self.infoObject.descriptionText;
    self.promptImageView.image = self.infoObject.promptImage;
    self.guessLabel.text = [NSString stringWithFormat:@"%ld",(long)self.infoObject.guessNumber];
    self.guessLabel.hidden = !self.infoObject.isNotShowMask;
    [self showGuess:self.infoObject.isShowGuess];
    
    if (!self.infoObject.isNotShowMask) {
        [self.promptImageView maskWithImage:[self.infoObject.maskImage imageByApplyingAlpha:.4]];
    }else{
        [self.promptImageView maskWithImage:self.treasureMapImageView.image];
    }
    
}

#pragma mark - HTWBleNfcControllerDelegate

-(void)bleNFCerror:(NSError *)error
{
    if ([error.domain isEqualToString:ble_nfc_error_domian]) {
        [self.blenfc powerOff];
    }else{
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

-(void)keyClick
{
    if (!self.infoObject.isNotShowMask) {
        self.infoObject.isNotShowMask = YES;
        [UIView animateWithDuration:1.0 animations:^{
            self.promptImageView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.promptImageView maskWithImage:self.treasureMapImageView.image];
            [UIView animateWithDuration:2.0 animations:^{
                self.promptImageView.alpha = 1;
            }];
        }];
    }else if (!self.infoObject.isShowGuess) {
        self.infoObject.isShowGuess = YES;
        
        [UIView animateWithDuration:2.0 animations:^{
            [self showGuess:self.infoObject.isShowGuess];
        }];
    }else if (self.infoObject.isShowGuess) {
        self.infoObject.isShowGuess = NO;
        
        [UIView animateWithDuration:2.0 animations:^{
            [self showGuess:self.infoObject.isShowGuess];
        }];
    }
    
}

-(void)keyConnect:(BOOL)connect
{
    [UIView animateWithDuration:2.0 animations:^{
        self.angelImageView.alpha = connect?.1:0;
    }];
    
    if (!connect) {
        [self.blenfc startScan];
    }
}

@end
