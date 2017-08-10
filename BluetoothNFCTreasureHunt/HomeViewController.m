//
//  HomeViewController.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/19.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "HomeViewController.h"
#import "HTWBleNfcController.h"
#import "NFCScanViewController.h"
#import "GuessNumberObject.h"

@interface HomeViewController ()<HTWBleNfcControllerDelegate>
@property (nonatomic,strong) HTWBleNfcController *blenfc;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (nonatomic) BOOL isBleConnect;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.blenfc = [HTWBleNfcController sharedInstance];
//    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - 生命週期相關

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.blenfc.delegate = self;
    self.isBleConnect = self.blenfc.isBleConnect;
    [self.navigationController setNavigationBarHidden:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - 檢查相關

-(void)checkBleStatus
{
    self.startButton.hidden = !self.isBleConnect;
    self.editButton.hidden = !self.isBleConnect;
    self.searchButton.hidden = self.isBleConnect;
    if (!self.isBleConnect) {
        self.versionLabel.text = nil;
    }
}

#pragma mark - 設定相關

-(void)setIsBleConnect:(BOOL)isBleConnect
{
    _isBleConnect = isBleConnect;
    [self checkBleStatus];
}

#pragma mark - 按鈕相關

- (IBAction)doStartButton:(id)sender {

}

- (IBAction)doSearchButton:(id)sender {
    if (!self.isBleConnect) {
        [self.blenfc startScan];
    }
}

- (IBAction)doEditButton:(id)sender {
}

#pragma mark - HTWBleNfcControllerDelegate

-(void)bleNFCready
{
    self.versionLabel.text = [NSString stringWithFormat:@"BLE NFC 版本:%ld\n電量:%f",(long)self.blenfc.version,self.blenfc.electricity];
    self.isBleConnect = YES;
}

-(void)bleNFCerror:(NSError *)error
{
    if ([error.domain isEqualToString:ble_nfc_error_domian]) {

    }else{
        self.isBleConnect = NO;
    }
}

@end
