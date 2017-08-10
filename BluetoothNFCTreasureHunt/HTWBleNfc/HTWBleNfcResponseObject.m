//
//  HTWBleNfcResponseObject.m
//  BluetoothNFCTreasureHunt
//
//  Created by Rex on 2017/5/7.
//  Copyright © 2017年 Rex. All rights reserved.
//

#import "HTWBleNfcResponseObject.h"

#define  MAX_FRAME_NUM                  63
#define  MAX_FRAME_LEN                  20
#define  MAX_FRAME_DATA_LEN             (MAX_FRAME_NUM * MAX_FRAME_LEN)
#pragma mark - command 相關
#define  GET_VERSIONS_COM        ((Byte)0x71)            //获取设备版本号指令

//Comand run result define
#define  COMAND_RUN_SUCCESSFUL   ((Byte)0x90)            //命令运行成功
#define  COMAND_RUN_ERROR        ((Byte)0x6E)            //命令运行出错

@interface HTWBleNfcResponseObject()

@property(nonatomic,strong) NSMutableArray<NSData *> *frames;
@property(nonatomic) int frameNum;
@property(nonatomic) HTWBleNfcCommand com;
@property(nonatomic) BOOL comRunStatus;
@property(nonatomic) HTWBleNfcResponseStatus status;

@property(nonatomic) int last_frame_num;
@end

@implementation HTWBleNfcResponseObject


#pragma mark - 分析相關
-(BOOL)analysisWithData:(NSData *)rcvData
{
    int this_frame_num = 0;
    HTWBleNfcResponseStatus status = HTWBleNfcResponseStatusIdle;
    Byte *bytes = (Byte *)[rcvData bytes];
    
    //開始frame還是後續frame
    if ( (bytes[0] & 0xC0) == 0x00) {   //開始frame
        //開始frame要大於4
        if (rcvData.length < 4) {
            return NO;
        }
        self.frameNum = bytes[0] & 0x3F;
        self.com = [[self class] commandWithByte:bytes[1] - 1];
        self.comRunStatus = (bytes[2] == COMAND_RUN_SUCCESSFUL);
        self.data = [[rcvData subdataWithRange:NSMakeRange(4, (int)rcvData.length - 4)] mutableCopy];
        self.last_frame_num = 0;
        if (self.frameNum > 0) {
            status = HTWBleNfcResponseStatusFollow;
        }else{
            status = HTWBleNfcResponseStatusComplete;
        }
    }else if ((bytes[0] & 0xC0) == 0xC0){   //後續frame
        //開始frame要大於2
        if (rcvData.length < 2) {
            return NO;
        }
        this_frame_num = bytes[0] & 0x3F;
        if (this_frame_num != (self.last_frame_num + 1) ) {        //序號不對
            status = HTWBleNfcResponseStatusIdle;
        }else{
            if ( MAX_FRAME_DATA_LEN < (self.data.length + rcvData.length - 1) ) {
                status = HTWBleNfcResponseStatusIdle;
            }else{
                [(NSMutableData *)self.data appendData:[rcvData subdataWithRange:NSMakeRange(1, (int)rcvData.length - 1)]];
                if (this_frame_num == self.frameNum){
                    if ( MAX_FRAME_DATA_LEN < self.data.length) {
                        status = HTWBleNfcResponseStatusIdle;
                    }else{
                        status = HTWBleNfcResponseStatusComplete;
                    }
                }else{
                    self.last_frame_num = this_frame_num;
                    status = HTWBleNfcResponseStatusFollow;
                }
            }
        }

    }else {
        status = HTWBleNfcResponseStatusIdle;
    }
    self.status = status;
    if (status == HTWBleNfcResponseStatusIdle) {
        return NO;
    }else if (HTWBleNfcResponseStatusComplete){
        self.last_frame_num = 0;
        
    }
    return YES;
}

#pragma mark - 取得相關

-(NSMutableArray<NSData *> *)frames
{
    if (!_frames) {
        self.frames = [NSMutableArray array];
    }
    return _frames;
}


#pragma mark - 設定相關

-(void)setStatus:(HTWBleNfcResponseStatus)status
{
    _status = status;
    if (status == HTWBleNfcResponseStatusIdle) {
        self.last_frame_num = 0;
        self.frameNum = 0;
        self.com = HTWBleNfcCommandNone;
        self.data = nil;
        self.comRunStatus = NO;
    }
    
}

#pragma mark - class mothed 相關

+(NSDictionary *)commandDictionary
{
    static NSDictionary *temp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        temp = @{
                 @(HTWBleNfcCommandMifareKey):@(0x40),
                 @(HTWBleNfcCommandMifareCom):@(0x41),
                 @(HTWBleNfcCommandActuvate_picc):@(0x62),
                 @(HTWBleNfcCommandElectricity):@(0x70),
                 @(HTWBleNfcCommandVersion):@(0x71),
                 @(HTWBleNfcCommandOff):@(0x6E),
                 };
    });
    return temp;
}

+(HTWBleNfcCommand)commandWithByte:(Byte)byte
{
    NSDictionary *temp = [self commandDictionary];
    for (NSNumber *commandKey in temp.allKeys) {
        Byte tempByte = (Byte)[temp[commandKey] intValue];
        if (tempByte == byte) {
            return [commandKey intValue];
        }
    }
    return HTWBleNfcCommandNone;
}

+(Byte)byteWithCommand:(HTWBleNfcCommand)command
{
    NSDictionary *temp = [self commandDictionary];
    Byte byte = (Byte)[temp[@(command)] intValue];
    return byte;
}

+(NSData *)dataWithCommand:(HTWBleNfcCommand)command
{
    NSData *data;
    if (command == HTWBleNfcCommandActuvate_picc) {
        Byte comBytes[] = {0x00, [self byteWithCommand:command],0x00};
        data = [NSData dataWithBytes:comBytes length:3];
    }else{
        Byte comBytes[] = {0x00, [self byteWithCommand:command]};
        data = [NSData dataWithBytes:comBytes length:2];
    }
    return data;
}

+(HTWBleNfcCommand)commandWithData:(NSData *)rcvData
{
    Byte *bytes = (Byte *)[rcvData bytes];
    
    //開始frame還是後續frame
    if ( (bytes[0] & 0xC0) == 0x00) {   //開始frame
        //開始frame要大於4
        if (rcvData.length < 4) {
            return NO;
        }
        return [self  commandWithByte:bytes[1] - 1];
    }else{
        return HTWBleNfcCommandNone;
    }
}

@end
