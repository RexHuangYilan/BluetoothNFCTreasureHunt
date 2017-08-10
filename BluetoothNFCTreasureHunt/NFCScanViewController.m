//
//  NFCScanViewController.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/19.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "NFCScanViewController.h"
#import "HTWBleNfcController.h"
#import "MifareCardManager.h"
#import "NSData+Hex.h"
#import "RFIDManager.h"
#import "RFIDInfoViewController.h"
#import "RFIDInfoCollectionViewCell.h"
#import "UIView+Border.h"
#import "GuessNumberViewController.h"
#import "BorderButton.h"
#import "UIView+Animation.h"

@interface NFCScanViewController ()<HTWBleNfcControllerDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,GuessNumberViewControllerDelegate>

@property (readonly) HTWBleNfcController *blenfc;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *answerLabel;
@property (weak, nonatomic) IBOutlet UIButton *readButton;
@property (weak, nonatomic) IBOutlet UIView *readView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *treasureButton;
@property (strong, nonatomic) RFIDInfoObject *rfidObject;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet BorderButton *guessNumberButton;

@property (strong, nonatomic) NSMutableArray<RFIDInfoObject *> *dataSource;
@property (strong, nonatomic) NSMutableArray<RFIDInfoObject *> *randomRFID;
@end

@implementation NFCScanViewController

#pragma mark - 生命週期相關

-(void)viewDidLoad
{
    [super viewDidLoad];
    id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
    UIWindow *window = appDelegate.window;
    UIViewController *vc = window.rootViewController;
    CGFloat width = vc.view.frame.size.width;
    CGAffineTransform transform = CGAffineTransformMakeScale(width/375.0,width/375.0);
    self.view.transform = transform;
    
    CATransform3D transform3d = CATransform3DMakeRotation(M_PI*70.0/180.0,1,0,0.0);   //旋轉
    self.readView.layer.transform = transform3d;
    
    
    self.dataSource = [NSMutableArray array];
    self.randomRFID = [[RFIDManager RFIDinfoObjects] mutableCopy];
    
    [self.treasureButton border];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.blenfc.delegate = self;
    [self.navigationController setNavigationBarHidden:YES];
    [self.readButton startAnimation];
    [self.collectionView reloadData];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.readButton endAnimation];
}

#pragma mark - 檢查相關

-(void)checkTreasures
{
    if (self.dataSource.count == [RFIDManager RFIDinfoObjects].count && ![self checkNumber]) {
        self.guessNumberButton.hidden = NO;
        [self showAllMask];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"恭喜寶物收集完成!!!!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"猜數字" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showGame];
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

-(BOOL)checkNumber
{
    if (self.dataSource.count != [RFIDManager RFIDinfoObjects].count) {
        return NO;
    }
    return [[RFIDManager RFIDinfoObjects] isEqualToArray:self.dataSource];
}

#pragma mark - 功能相關

-(void)showAllMask
{
    for (RFIDInfoObject *obj in [RFIDManager RFIDinfoObjects]) {
        obj.isNotShowMask = YES;
    }
}

-(void)win
{
    if ([self checkNumber]) {
        self.guessNumberButton.hidden = YES;
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"過關!!!" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"恭喜啦" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - 寶物相關

-(void)appendTreasure:(RFIDInfoObject *)treasure
{
    NSInteger index = [self indexWithRfid:treasure.rfid];
    if (index == NSNotFound) {
        [self.dataSource addObject:treasure];
        [self checkTreasures];
    }else{
        [self lastWithRfid:treasure.rfid];
    }
    [self.collectionView reloadData];
    if ([self checkNumber]) {
        [self win];
    }
}

-(NSInteger)indexWithRfid:(NSString *)rfid
{
    if (rfid.length == 0) {
        return NSNotFound;
    }
    BOOL isFind = NO;
    NSInteger index = 0;
    for (RFIDInfoObject * obj in self.dataSource) {
        if ([obj.rfid isEqualToString:rfid]) {
            isFind = YES;
            break;
        }
        index++;
    }
    return isFind?index:NSNotFound;
}

-(void)lastWithRfid:(NSString *)rfid
{
    if (rfid.length == 0) {
        return;
    }
    for (RFIDInfoObject * obj in self.dataSource) {
        if ([obj.rfid isEqualToString:rfid]) {
            [self.dataSource removeObject:obj];
            [self.dataSource addObject:obj];
            break;
        }
    }
}

-(void)showTreasure:(RFIDInfoObject *)treasure
{
    if (!treasure) {
        return;
    }
    RFIDInfoViewController *vc = [RFIDInfoViewController viewControllerWithRFID:treasure];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

-(void)showGame
{
    if (self.dataSource.count != [RFIDManager RFIDinfoObjects].count) {
        return;
    }
    GuessNumberViewController *vc = [GuessNumberViewController viewController];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

#pragma mark - 設定相關

-(void)setRfidObject:(RFIDInfoObject *)rfidObject
{
    _rfidObject = rfidObject;
    self.nameLabel.text = rfidObject?rfidObject.name:@"該寶物不存在";
    [self.treasureButton setImage:rfidObject?rfidObject.maskImage:nil forState:UIControlStateNormal];
    self.treasureButton.hidden = (rfidObject == nil);
}

-(void)setRandomRFID:(NSMutableArray<RFIDInfoObject *> *)randomRFID
{
    for (NSUInteger i = randomRFID.count - 1; i > 0; --i) {
        NSUInteger n = arc4random() % (i+1);
        [randomRFID exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    _randomRFID = randomRFID;
}

#pragma mark - 取得相關


-(HTWBleNfcController *)blenfc
{
    return [HTWBleNfcController sharedInstance];
}

#pragma mark - 按鈕相關

- (IBAction)doReadButton:(id)sender {
    [self.blenfc searchCard];
}

- (IBAction)doTreasureButton:(id)sender {
    if (!self.rfidObject) {
        return;
    }
    NSInteger index = [self.randomRFID indexOfObject:self.rfidObject];
    index = (index == self.randomRFID.count - 1)?0:index + 1;
    RFIDInfoObject *temp = [self.randomRFID objectAtIndex:index];
    [self showTreasure:temp];
}

- (IBAction)doGuessNumberButton:(id)sender {
    [self showGame];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSArray *rowData = self.dataSource;
    return rowData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    RFIDInfoObject *object = self.dataSource[indexPath.row];
    
    NSString *identifier = @"RFIDinfoCollectionCell";
    RFIDInfoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.imageView.image = object.maskImage;
    cell.guessLabel.text = object.isShowGuess?[NSString stringWithFormat:@"%ld",(long)object.guessNumber]:@"";
    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(8, 8, 8, 8);
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    RFIDInfoObject *object = self.dataSource[indexPath.row];
    [self showTreasure:object];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = collectionView.frame.size.height - 8 * 2;
    return CGSizeMake(height, height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

#pragma mark - HTWBleNfcControllerDelegate

-(void)bleNFCResponse:(HTWBleNfcResponseObject *)response
{
    NSLog(@"response:%@",response.data);
    if (response.com == HTWBleNfcCommandActuvate_picc) {
        NSString *rfid = [(HTWBleNfcActuvatePiccObject *)response uid].convertDataToHexStr;
        RFIDInfoObject *obj = [RFIDManager objectWithRfid:rfid];
        if (obj) {
            [self appendTreasure:obj];
        }
        self.rfidObject = obj;
        [self.blenfc powerOff];
    }
}

-(void)bleNFCerror:(NSError *)error
{
    if ([error.domain isEqualToString:ble_nfc_error_domian]) {
        if (error.code == HTWBleNfcCommandErrorActuvate_picc) {
            self.rfidObject = nil;
            self.nameLabel.text = @"沒有找到任何寶物";
        }
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

#pragma mark - GuessNumberViewControllerDelegate

//解答成功
-(void)isSuccess
{
    self.guessNumberButton.hidden = YES;
    self.answerLabel.text = [RFIDManager answer];
}

@end
