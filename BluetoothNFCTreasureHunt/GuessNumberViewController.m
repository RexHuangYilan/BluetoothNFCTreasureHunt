//
//  GuessNumberViewController.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/6/1.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "GuessNumberViewController.h"
#import "RFIDManager.h"
#import "GuessNumberObject.h"

#define CLEARNUMBER 10
#define INPUTNUMBER 11

@interface GuessNumberViewController ()

@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UITextView *historyTextView;

@property (readwrite) NSString *number;
@property (readwrite) NSString *history;
@property (readonly) NSInteger numberCount;

@property (strong, nonatomic) GuessNumberObject *guessNumberObject;

@end

@implementation GuessNumberViewController

+(instancetype)viewController
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GuessNumberViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"GuessNumberViewController"];

    return vc;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.guessNumberObject = [GuessNumberObject new];
    self.guessNumberObject.answer = [RFIDManager answer];
}

#pragma mark - 設定相關

-(void)setNumber:(NSString *)number
{
    self.numberTextField.text = number;
}

-(void)setHistory:(NSString *)history
{
    self.historyTextView.text = history;
}

#pragma mark - 取得相關

-(NSString *)number
{
    return self.numberTextField.text;
}

-(NSString *)history
{
    return self.historyTextView.text;
}

-(NSInteger)numberCount
{
    return [RFIDManager RFIDinfoObjects].count;
}

#pragma mark - 輸入相關

-(void)appendKey:(NSString *)key
{
    if (self.number.length < self.numberCount) {
        self.number = [NSString stringWithFormat:@"%@%@",self.number?self.number:@"",key];
    }
}

-(void)appendHistory:(NSString *)history
{
    if (self.history) {
        self.history = [NSString stringWithFormat:@"%@\n%@",self.history,history];
    }else{
        self.history = [NSString stringWithFormat:@"%@",history];
    }
}

#pragma mark - 檢查相關

-(BOOL)checkNumberCount
{
    if (self.number.length != self.numberCount) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"要輸入 %ld 個數字喔~",(long)self.numberCount] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    return YES;
}

-(void)checkIsEqual
{
    if (self.guessNumberObject.isEqual) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"冒險者，看來你找到正確的答案(%@)了，但這還不是結束，你找的到寶物都隱藏一個數字，現在依答案順序將寶物放到祭壇吧，你將會看發現最終的密寶!!!",[RFIDManager answer]] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"確認" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:^{
                if ([self.delegate respondsToSelector:@selector(isSuccess)]) {
                    [self.delegate isSuccess];
                }
            }];
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

#pragma mark - 按鈕相關

- (IBAction)doKeyButton:(UIButton *)sender {
    if (sender.tag > INPUTNUMBER) {
        return;
    }
    
    if (sender.tag == CLEARNUMBER) {
        [self removeInput];
    }else if (sender.tag == INPUTNUMBER) {
        [self guessNumber];
    }else{
        [self appendKey:[NSString stringWithFormat:@"%ld",(long)sender.tag]];
    }
}

- (IBAction)doClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)removeInput
{
    self.number = nil;
}

#pragma mark - 猜數字相關

-(void)guessNumber
{
    if (![self checkNumberCount]) {
        return;
    }
    self.guessNumberObject.reply = self.number;
    NSString *answer = [NSString stringWithFormat:@"%ldA%ldB",(long)self.guessNumberObject.a,(long)self.guessNumberObject.b];
    [self appendHistory:[NSString stringWithFormat:@"%@ -%@",self.number,answer]];
    [self removeInput];
    [self checkIsEqual];
    
}

@end
