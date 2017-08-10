//
//  NFCWriteViewController.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/24.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "NFCWriteViewController.h"
#import "HTWBleNfcController.h"
#import "RFIDTableViewCell.h"
#import "RFIDManager.h"
#import "RFIDEditViewController.h"

@interface NFCWriteViewController ()<HTWBleNfcControllerDelegate,UITableViewDelegate,UITableViewDataSource>
@property (readonly) HTWBleNfcController *blenfc;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,weak) NSArray<RFIDInfoObject *> *dataSource;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@end

@implementation NFCWriteViewController

#pragma mark - 生命週期相關

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self checkEditMode];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.blenfc.delegate = self;
    [self.tableView reloadData];
    [self.navigationController setNavigationBarHidden:NO];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - 功能相關

- (IBAction)doAddRfid:(id)sender {
    
}

- (IBAction)doEditMode:(id)sender {
    self.tableView.editing = !self.tableView.editing;
    [self checkEditMode];
}

#pragma mark - 檢查相關

-(void)checkEditMode
{
    if (self.tableView.editing) {
        self.editButton.title = @"完成";
    }else{
        self.editButton.title = @"移動";
    }
}

#pragma mark - 設定相關

#pragma mark - 取得相關

-(HTWBleNfcController *)blenfc
{
    return [HTWBleNfcController sharedInstance];
}

-(NSArray<RFIDInfoObject *> *)dataSource
{
    return [RFIDManager RFIDinfoObjects];
}

#pragma mark - HTWBleNfcControllerDelegate

-(void)bleNFCResponse:(HTWBleNfcResponseObject *)response
{
    NSLog(@"response:%@",response.data);
    if (response.com == HTWBleNfcCommandActuvate_picc) {
//        self.rfid = [NSString stringWithFormat:@"寶物序號:%@",[(HTWBleNfcActuvatePiccObject *)response uid].convertDataToHexStr];
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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"RFIDCell";
    RFIDTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(RFIDTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RFIDInfoObject *obj = self.dataSource[indexPath.row];
    cell.object = obj;
}

//- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(ProductHomeBaseTableViewCell *)cell forRowAtIndexPath:(NSIndexPath*)indexPath{
//    cell.isVisible = NO;
//}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    RFIDInfoObject *obj = self.dataSource[indexPath.row];
    RFIDEditViewController *vc = [RFIDEditViewController viewControllerWithRFID:obj];
    [self.navigationController pushViewController:vc animated:YES];
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableView.editing?UITableViewCellEditingStyleNone:UITableViewCellEditingStyleDelete;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
        {
            RFIDInfoObject *obj = self.dataSource[indexPath.row];
            [RFIDManager removeRfid:obj.rfid];
            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [tableView endUpdates];
        }
            break;
        default:
            break;
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toIndexPath:(nonnull NSIndexPath *)destinationIndexPath
{
    RFIDInfoObject *obj = self.dataSource[sourceIndexPath.row];
    [RFIDManager removeRfid:obj.rfid];
    [RFIDManager insertData:obj atIndex:destinationIndexPath.row];
    
    [tableView beginUpdates];
    [tableView moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
    [tableView endUpdates];
}

@end
