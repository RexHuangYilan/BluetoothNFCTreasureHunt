//
//  HTWBleNfcController.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/6.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "HTWBleNfcController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "HTWBleNfcResponseObject.h"
#import "HTWBleNfcVersionObject.h"
#import "HTWBleNfcElectricityObject.h"
#import "HTWBleNfcActuvatePiccObject.h"

#define SEARCH_BLE_NAME   @"BLE_NFC"
#define DK_SERVICE_UUID            @"FFF0"
#define DK_APDU_CHANNEL_UUID       @"FFF2"

#define SEARCH_KEY_NAME   @"iTAG            "
#define KEY_SERVICE_UUID            @"FFE0"
#define KEY_PUSH_UUID            @"FFE1"


NSErrorDomain ble_nfc_error_domian = @"ble.nfc.error";

@interface HTWBleNfcController()<CBCentralManagerDelegate,CBPeripheralDelegate>
@property (nonatomic,strong) CBCentralManager *manager;
@property (nonatomic,strong) CBPeripheral *peripheral;
@property (nonatomic,strong) CBPeripheral *keyPeripheral;
@property (nonatomic,weak) CBCharacteristic *characteristic;

@property (nonatomic,strong) HTWBleNfcResponseObject *responseObject;
@property(nonatomic) NSInteger version;
@property(nonatomic) float electricity;
@property (nonatomic) BOOL isBleConnect;
@end

@implementation HTWBleNfcController

#pragma mark - 初始化相關

+ (instancetype)sharedInstance{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init {
    self = [super init];//获得父类的对象并进行初始化
    if (self){
        self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

#pragma mark - 掃描相關

-(void)startScan {

    if (self.manager == nil) {
        return;
    }
    if (self.manager.state != CBManagerStatePoweredOn) {
        return;
    }
    [self.manager scanForPeripheralsWithServices:nil options:nil];
}

-(void)stopScan{
    if (self.manager == nil) {
        return;
    }
    [self.manager stopScan];
}

#pragma mark - 功能相關

-(void)removeKeyPeripheral
{
    if (self.keyPeripheral) {
        [self.manager cancelPeripheralConnection:self.keyPeripheral];
    }
}

#pragma mark - 設定相關

-(void)setPeripheral:(CBPeripheral *)peripheral
{
    _peripheral = peripheral;
    peripheral.delegate = self;
    [self.manager connectPeripheral:peripheral options:nil];
    [self stopScan];
}

-(void)setKeyPeripheral:(CBPeripheral *)keyPeripheral
{
    _keyPeripheral = keyPeripheral;
    keyPeripheral.delegate = self;
    [self.manager connectPeripheral:keyPeripheral options:nil];
    [self stopScan];
}

-(void)setCharacteristic:(CBCharacteristic *)characteristic
{
    _characteristic = characteristic;
    [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
    [self getVersion];
}

-(void)setVersion:(NSInteger)version
{
    _version = version;
    [self getElectricity];
}

-(void)setElectricity:(float)electricity
{
    _electricity = electricity;
    NSLog(@"version:%ld 電量:%f",(long)self.version,electricity);
    if (self.version > 0 && electricity > 0) {
        self.isBleConnect = YES;
        if ([self.delegate respondsToSelector:@selector(bleNFCready)]) {
            [self.delegate bleNFCready];
        }
    }
}

#pragma mark - 取得藍牙資料

-(void)getVersion
{
    NSData *data = [HTWBleNfcResponseObject dataWithCommand:HTWBleNfcCommandVersion];
    [self writeData:data];
}

-(void)getElectricity
{
    NSData *data = [HTWBleNfcResponseObject dataWithCommand:HTWBleNfcCommandElectricity];
    [self writeData:data];
}

//查詢卡片
-(void)searchCard
{
    NSData *data = [HTWBleNfcResponseObject dataWithCommand:HTWBleNfcCommandActuvate_picc];
    [self writeData:data];
}

#pragma mark - CBCentralManagerDelegate
//中心設備狀態更新事件
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"Manager State:%ld",(long)central.state);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    int iRssi = abs(RSSI.intValue);
    float power = (iRssi-59)/(10*2.0);
    float distance = pow(10, power);
    NSLog(@"找到設備名稱：%@ %@", peripheral.name, RSSI);
    NSLog(@"distance:%f",distance);

    if ([peripheral.name isEqualToString:SEARCH_BLE_NAME]) {
        NSLog(@"找到設備：%@ %@", peripheral, RSSI);
        self.peripheral = peripheral;
    }else if ([peripheral.name isEqualToString:SEARCH_KEY_NAME] && self.peripheral) {
        NSLog(@"找到Key設備：%@ %@", peripheral, RSSI);
        self.keyPeripheral = peripheral;
    }
}

//外設連線成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"%@ 連線成功",peripheral.name);
    [peripheral discoverServices:nil];
}

//外設連線失敗
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    NSLog(@"%@ 連線失敗:%@",peripheral.name,error);
    self.isBleConnect = NO;
    if ([self.delegate respondsToSelector:@selector(bleNFCerror:)]) {
        [self.delegate bleNFCerror:error];
    }
}

//外設連線中斷
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    NSLog(@"%@ 連線中斷",peripheral.name);
    if (peripheral == self.peripheral) {
        self.isBleConnect = NO;
        if ([self.delegate respondsToSelector:@selector(bleNFCerror:)]) {
            [self.delegate bleNFCerror:error];
        }
    }else if (peripheral == self.keyPeripheral) {
        if ([self.delegate respondsToSelector:@selector(keyConnect:)]) {
            [self.delegate keyConnect:NO];
        }
    }
}

#pragma mark - CBPeripheralDelegate

//服務查詢完畢
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        self.isBleConnect = NO;
        NSLog(@"DiscoverServices Error:%@",error);
    }else{
        NSLog(@"servers:%@", peripheral.services);
        if (peripheral == self.peripheral) {
            for (CBService *theService in peripheral.services) {
                if ([theService.UUID.UUIDString isEqualToString:DK_SERVICE_UUID]) {
                    [peripheral discoverCharacteristics:nil forService:theService];
                    return;
                }
            }
        }else if (peripheral == self.keyPeripheral) {
            for (CBService *theService in peripheral.services) {
                if ([theService.UUID.UUIDString isEqualToString:KEY_SERVICE_UUID]) {
                    [peripheral discoverCharacteristics:nil forService:theService];
                    return;
                }
            }
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error
{
    if (error) {
        self.isBleConnect = NO;
        NSLog(@"didDiscoverCharacteristicsForService Error:%@",error);
    }
    if (peripheral == self.peripheral) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            NSLog(@"UUID:%@",characteristic.UUID.UUIDString);
            if ([characteristic.UUID.UUIDString isEqualToString:DK_APDU_CHANNEL_UUID]) {
                self.characteristic = characteristic;
                return;
            }else{
                [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
    }else if (peripheral == self.keyPeripheral) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            NSLog(@"UUID:%@",characteristic.UUID.UUIDString);
            if ([characteristic.UUID.UUIDString isEqualToString:KEY_PUSH_UUID]) {
                [self.keyPeripheral setNotifyValue:YES forCharacteristic:characteristic];
                if ([self.delegate respondsToSelector:@selector(keyConnect:)]) {
                    [self.delegate keyConnect:YES];
                }
                return;
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    NSLog(@"接收到資料%@", characteristic.value);
    if (peripheral == self.keyPeripheral && [characteristic.UUID.UUIDString isEqualToString:KEY_PUSH_UUID]) {
        if ([self.delegate respondsToSelector:@selector(keyClick)]) {
            [self.delegate keyClick];
        }
        return;
    }
    
    if (!self.responseObject) {
        Class class;
        HTWBleNfcCommand com = [HTWBleNfcResponseObject commandWithData:characteristic.value];
        switch (com) {
            case HTWBleNfcCommandVersion:
                class = [HTWBleNfcVersionObject class];
                break;
            case HTWBleNfcCommandElectricity:
                class = [HTWBleNfcElectricityObject class];
                break;
            case HTWBleNfcCommandActuvate_picc:
                class = [HTWBleNfcActuvatePiccObject class];
                break;
            default:
                class = [HTWBleNfcResponseObject class];
                break;
        }
        
        self.responseObject = [class new];
    }
    [self.responseObject analysisWithData:characteristic.value];
    if (self.responseObject.status == HTWBleNfcResponseStatusComplete && self.responseObject.comRunStatus) {
        switch (self.responseObject.com) {
            case HTWBleNfcCommandVersion:
                self.version = [(HTWBleNfcVersionObject *)self.responseObject version];
                break;
            case HTWBleNfcCommandElectricity:
                self.electricity = [(HTWBleNfcElectricityObject *)self.responseObject electricity];
                break;
            case HTWBleNfcCommandActuvate_picc:
                if ([self.delegate respondsToSelector:@selector(bleNFCResponse:)]) {
                    [self.delegate bleNFCResponse:self.responseObject];
                }
                break;
            default:
                if ([self.delegate respondsToSelector:@selector(bleNFCResponse:)]) {
                    [self.delegate bleNFCResponse:self.responseObject];
                }
                break;
        }
        
    }else{
        if ([self.delegate respondsToSelector:@selector(bleNFCerror:)]) {
            HTWBleNfcCommandError code = HTWBleNfcCommandErrorOther;
            switch (self.responseObject.com) {
                case HTWBleNfcCommandVersion:
                    code = HTWBleNfcCommandErrorVersion;
                    break;
                case HTWBleNfcCommandElectricity:
                    code = HTWBleNfcCommandErrorElectricity;
                    break;
                case HTWBleNfcCommandActuvate_picc:
                    code = HTWBleNfcCommandErrorActuvate_picc;
                    break;
                default:
                    code = HTWBleNfcCommandErrorOther;
                    break;
            }
            NSError *error = [NSError errorWithDomain:ble_nfc_error_domian code:code userInfo:nil];
            [self.delegate bleNFCerror:error];
        }
    }
    self.responseObject = nil;
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    
}

//發送訊息
-(Boolean)writeData:(NSData *)writeData{
    if (self.peripheral == nil) {
        return NO;
    }
    if (self.manager == nil) {
        return NO;
    }
    if (self.characteristic == nil) {
        return NO;
    }
    NSLog(@"送出資料:%@",writeData);
    [self.peripheral writeValue:writeData forCharacteristic:self.characteristic type:CBCharacteristicWriteWithoutResponse];

    return YES;
}

//關閉天線
-(void)powerOff
{
    [self writeData:[HTWBleNfcResponseObject dataWithCommand:HTWBleNfcCommandOff]];
}

@end
