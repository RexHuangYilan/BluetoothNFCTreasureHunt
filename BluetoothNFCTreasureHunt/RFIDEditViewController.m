//
//  RFIDEditViewController.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/27.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "RFIDEditViewController.h"
#import "UIView+Border.h"
#import <Photos/Photos.h>
#import "RFIDInfoObject.h"
#import "HTWBleNfcController.h"
#import "HTWBleNfcActuvatePiccObject.h"
#import "NSData+Hex.h"
#import "UIImage+ReDraw.h"

typedef NS_ENUM(NSUInteger, PhotoType) {
    PhotoTypePrompt,    //提示圖
    PhotoTypeMask,      //遮罩圖
};

@interface RFIDEditViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,HTWBleNfcControllerDelegate>
@property (readonly) HTWBleNfcController *blenfc;

@property (weak, nonatomic) IBOutlet UITextField *rfidTextField;
@property (weak, nonatomic) IBOutlet UIButton *scanButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *guessNumberTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *promptImageView;  //提示圖
@property (weak, nonatomic) IBOutlet UIButton *promptButton;
@property (weak, nonatomic) IBOutlet UIImageView *maskImageView;    //遮罩圖
@property (weak, nonatomic) IBOutlet UIButton *maskButton;

@property (nonatomic) PhotoType photoType;
@property (nonatomic) BOOL isNew;
@end

@implementation RFIDEditViewController
@synthesize infoObject = _infoObject;


+(instancetype)viewControllerWithRFID:(RFIDInfoObject *)rfid
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    RFIDEditViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"rfidEditVC"];
    vc.infoObject = rfid;
    return vc;
}

#pragma mark - 生命週期相關

- (void)viewDidLoad {
    [super viewDidLoad];
    [self synchronizeIntoToInput];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.blenfc.delegate = self;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - 設定相關

-(void)setDescriptionTextView:(UITextView *)descriptionTextView
{
    _descriptionTextView = descriptionTextView;
    [descriptionTextView border];
}

-(void)setPromptImageView:(UIImageView *)promptImageView
{
    _promptImageView = promptImageView;
    [promptImageView border];
}

-(void)setMaskImageView:(UIImageView *)maskImageView
{
    _maskImageView = maskImageView;
    [maskImageView border];
}

-(void)setPhotoImage:(UIImage *)image
{
    switch (self.photoType) {
        case PhotoTypePrompt:
            self.promptImageView.image = image;
            break;
        case PhotoTypeMask:
            self.maskImageView.image = image;
            break;
    }
}

-(void)setInfoObject:(RFIDInfoObject *)infoObject
{
    _infoObject = infoObject;
    self.isNew = infoObject.rfid.length == 0;
}

-(void)setRFID:(NSString *)rfid;
{
    RFIDInfoObject *obj = [RFIDManager objectWithRfid:rfid];
    if (obj) {
        self.infoObject = obj;
        [self synchronizeIntoToInput];
    }else{
        self.rfidTextField.text = rfid;
    }
}

#pragma mark - 取得相關

-(HTWBleNfcController *)blenfc
{
    return [HTWBleNfcController sharedInstance];
}

-(RFIDInfoObject *)infoObject{
    if (!_infoObject) {
        self.infoObject = [RFIDInfoObject new];
    }
    return _infoObject;
}

#pragma mark - 同步相關

-(void)synchronizeIntoToInput
{
    self.rfidTextField.text = self.infoObject.rfid;
    self.nameTextField.text = self.infoObject.name;
    self.guessNumberTextField.text = [NSString stringWithFormat:@"%ld",(long)self.infoObject.guessNumber];
    self.descriptionTextView.text = self.infoObject.descriptionText;
    self.promptImageView.image = self.infoObject.promptImage;
    self.maskImageView.image = self.infoObject.maskImage;
}

-(void)synchronizeInputToInfo
{
    self.infoObject.rfid = self.rfidTextField.text;
    self.infoObject.name = self.nameTextField.text;
    self.infoObject.guessNumber = [self.guessNumberTextField.text integerValue];
    self.infoObject.descriptionText = self.descriptionTextView.text;
    self.infoObject.promptImage = self.promptImageView.image;
    self.infoObject.maskImage = self.maskImageView.image;
}

#pragma mark - 按鈕相關

- (IBAction)doScanButton:(id)sender {
    [self.blenfc searchCard];
}

- (IBAction)doPromptButton:(id)sender {
    self.photoType = PhotoTypePrompt;
    [self selectPhoto];
}

- (IBAction)doMaskButton:(id)sender {
    self.photoType = PhotoTypeMask;
    [self selectPhoto];
}

- (IBAction)doDone:(id)sender {
    [self synchronizeInputToInfo];
    if (self.isNew) {
        [RFIDManager appendData:self.infoObject];
    }else{
        [RFIDManager updateData:self.infoObject];
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:self.isNew?@"新增完成":@"修改完成" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 照片相關

-(void)selectPhoto
{
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        switch (status) {
            case PHAuthorizationStatusRestricted:
            case PHAuthorizationStatusDenied:{
                NSLog(@"沒同意相片喔!!");
            }
                break;
            case PHAuthorizationStatusNotDetermined:
            case PHAuthorizationStatusAuthorized:{
                [self showImageList];
            }
                break;
        }
    }];
}

-(void)showImageList
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:imagePicker animated:YES completion:nil];
        });
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    UIImage *image;
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:@"public.image"]) {
        //取得圖片
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        UIImage *image2 = [UIImage drawImage:image width:self.view.frame.size.width];
        [self setPhotoImage:image2];
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - HTWBleNfcControllerDelegate

-(void)bleNFCResponse:(HTWBleNfcResponseObject *)response
{
    if (response.com == HTWBleNfcCommandActuvate_picc) {
        [self setRFID:[(HTWBleNfcActuvatePiccObject *)response uid].convertDataToHexStr];
        [self.blenfc powerOff];
    }
}

-(void)bleNFCerror:(NSError *)error
{
    if ([error.domain isEqualToString:ble_nfc_error_domian]) {
        [self.blenfc powerOff];
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
