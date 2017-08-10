//
//  ViewController.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/6.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "ViewController.h"
#import "HTWBleNfcController.h"
#import "HTWBleNfcActuvatePiccObject.h"
#import "MifareCardManager.h"
#import "NSData+Hex.h"


@interface ViewController ()<HTWBleNfcControllerDelegate>
@property (nonatomic,strong) HTWBleNfcController *blenfc;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UILabel *cardLabel;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UIButton *writeButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *searchCardButton;
@property (weak, nonatomic) IBOutlet UIButton *readButton;

@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

@property (nonatomic,strong) HTWBleNfcActuvatePiccObject *card;
@property (nonatomic) BOOL isCardVerification;
@property (nonatomic) BOOL isConnect;
@property (nonatomic) MifareComType type;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.blenfc = [[HTWBleNfcController alloc] init];
    self.blenfc.delegate = self;
    self.isConnect = NO;

}

#pragma mark - 設定相關

-(void)setIsConnect:(BOOL)isConnect
{
    _isConnect = isConnect;
    self.scanButton.hidden = isConnect;
    self.searchCardButton.hidden = !isConnect;
    self.card = nil;
}

-(void)setCard:(HTWBleNfcActuvatePiccObject *)card
{
    _card = card;
    if (card) {
        self.cardLabel.text = [NSString stringWithFormat:@"卡片序號:%@",card.uid.convertDataToHexStr];
        [self.blenfc writeData:[MifareCardManager keyWithCard:card]];
    }
    self.closeButton.hidden = !card;
    self.isCardVerification = NO;
}

-(void)setIsCardVerification:(BOOL)isCardVerification
{
    _isCardVerification = isCardVerification;
    self.writeButton.hidden = !isCardVerification;
    self.readButton.hidden = !isCardVerification;
}

#pragma mark - 功能相關

- (IBAction)doStart:(id)sender {
    [self.blenfc startScan];
}

- (IBAction)doSearchCardButton:(id)sender {
    self.card = nil;
    [self.blenfc searchCard];
}

- (IBAction)doCloseButton:(id)sender {
    [self.blenfc powerOff];
    self.card = nil;
}

- (IBAction)doWriteButton:(id)sender {
    self.type = MifareComTypeWriteReady;
    [self.blenfc writeData:[MifareCardManager writeComData]];
}

- (IBAction)doReadButton:(id)sender {
    self.type = MifareComTypeRead;
    [self.blenfc writeData:[MifareCardManager read]];
}

#pragma mark - HTWBleNfcControllerDelegate

-(void)bleNFCready
{
    self.versionLabel.text = [NSString stringWithFormat:@"BLE NFC 版本:%ld\n電量:%f",(long)self.blenfc.version,self.blenfc.electricity];
    self.isConnect = YES;
}

-(void)bleNFCerror:(NSError *)error
{
    if ([error.domain isEqualToString:ble_nfc_error_domian]) {
        self.card = nil;
    }else{
        self.isConnect = NO;
    }
}

-(void)bleNFCResponse:(HTWBleNfcResponseObject *)response
{
    NSLog(@"response:%@",response.data);
    if (response.com == HTWBleNfcCommandActuvate_picc) {
        self.card = (HTWBleNfcActuvatePiccObject *)response;
    }else if (response.com == HTWBleNfcCommandMifareKey) {
        self.isCardVerification = YES;
    }else if (response.com == HTWBleNfcCommandMifareCom) {
        switch (self.type) {
            case MifareComTypeRead:
                self.inputTextField.text = response.data.description;
                break;
            case MifareComTypeWriteReady:
                self.type = MifareComTypeWrite;
                [self.blenfc writeData:[MifareCardManager writeWithData:@"fffffffffffffffffffffffffffff".hexToBytes]];
                break;
            case MifareComTypeWrite:
                [self doReadButton:nil];
                break;
            default:
                break;
        }
    }
}

@end
