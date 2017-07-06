/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BluetoothServerManager.m
//  BlueDemo
//


#import "BLEPeripheralManager.h"
#import "BluetoothConfigDefine.h"
#import "BLEDataPack.h"


@interface BLEPeripheralManager ()<CBPeripheralManagerDelegate>{

    CBPeripheralManager *_serverCM;
    NSUUID *_lastDeviceUUID;
    
    NSMutableArray* dataPackList; ///< 待发送报文列表
    BLEDataPack* sendingDataPack; ///< 当前正在发送报文
}

@property (nonatomic,strong) CBCentral *central;
@property (nonatomic,strong) CBMutableCharacteristic *notiyCharacteristic;

@end

@implementation BLEPeripheralManager

@synthesize serverManager=_serverCM;

+ (BLEPeripheralManager *)shareInstance
{
    static dispatch_once_t pred = 0;
    __strong static BLEPeripheralManager *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id)init{
    
    if (self=[super init]) {
        dataPackList = [NSMutableArray arrayWithCapacity:10];
        self.bluetoothState=BluetoothStateUnknown;
        _serverCM=[[CBPeripheralManager alloc]initWithDelegate:self queue:nil];
    }
    return self;
}

#pragma  mark -- CBPeripheralManagerDelegate

/*
 * 状态改变
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{

    BluetoothState bleState=peripheral.state==CBPeripheralManagerStatePoweredOn?BluetoothStateOpen:BluetoothStateClose;
    
    if (self.bluetoothState!=bleState) {
        
        self.bluetoothState=bleState;
        
        [self startService];
        
        BOOL isOpen=self.bluetoothState==BluetoothStateOpen?YES:NO;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothStateChangedNotification object:peripheral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isOpen],@"state", nil]];
        
    }
}
/*
 * 添加服务完成后，发送广播
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error == nil) {
        //服务添加完成后发送广播
        //添加服务后可以在此向外界发出通告 调用完这个方法后会调用代理的
        //(void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
        [_serverCM startAdvertising:@{CBAdvertisementDataServiceUUIDsKey : @[[CBUUID UUIDWithString:kBluetoottServiceUUID]],
                                      CBAdvertisementDataLocalNameKey : [UIDevice currentDevice].name}];
    }

}
/*
 * 开始发送广播
 */
- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error{
    if (error) {
         NSLog(@"开始发送广播,失败原因=%@",error.description);
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request{

    //判断是否有读数据的权限
    if (request.characteristic.properties & CBCharacteristicPropertyRead) {
        NSData *data = request.characteristic.value;
        [request setValue:data];
        //对请求作出成功响应
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
        
    }else{
        //错误的响应
        [peripheral respondToRequest:request withResult:CBATTErrorReadNotPermitted];
    }
    

}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray*)requests{

    CBATTRequest *request = requests[0];
    
    //判断是否有写数据的权限
    if (request.characteristic.properties & CBCharacteristicPropertyWrite) {
        //需要转换成CBMutableCharacteristic对象才能进行写值
        CBMutableCharacteristic *c =(CBMutableCharacteristic *)request.characteristic;
        c.value = request.value;
        [_serverCM respondToRequest:request withResult:CBATTErrorSuccess];
        
        //中心发过来的数据
        if (self.receiveDataCompletedBlock) {
            self.receiveDataCompletedBlock(c.value);
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kBLEPeripheralReceivePartialDataNotification object:c.value];
        
    }else{
        [_serverCM respondToRequest:request withResult:CBATTErrorWriteNotPermitted];
    }
}


#pragma mark -订阅
//central订阅了characteristic的值，当更新值的时候peripheral会调用
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    
    self.central = central;
    if (_lastDeviceUUID == central.identifier) {
        return;
    }
    _lastDeviceUUID = central.identifier;

    [self sendBLEDataPack];
}
//This method is invoked after a failed call to
//peripheral再次准备好发送Characteristic值的更新时候调用
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral{
    //[self sendData];
    [self sendBLEDataPack];
    
}
//当central取消订阅characteristic这个特征的值后调用方法
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{

}

#pragma mark -私有方法
/**
 *  添加服务
 */
- (void)startService
{

    if(self.bluetoothState!=BluetoothStateOpen)
    {
        return;
    }
    
    //characteristics字段描述
    CBUUID *CBUUIDCharacteristicUserDescriptionStringUUID = [CBUUID UUIDWithString:CBUUIDCharacteristicUserDescriptionString];
    
    /*
     可以通知的Characteristic
     properties：CBCharacteristicPropertyNotify
     permissions CBAttributePermissionsReadable
     */
    self.notiyCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:kBluetoottNotiyCharacteristicUUID] properties:CBCharacteristicPropertyNotify value:nil permissions:CBAttributePermissionsReadable];
    
    /*
     可读写的characteristics
     properties：CBCharacteristicPropertyWrite | CBAttributePermissionsWriteable
     */
    CBMutableCharacteristic *readwriteCharacteristic = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:kBluetoottReadwriteCharacteristicUUID] properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable];
    //设置description
    CBMutableDescriptor *readwriteCharacteristicDescription1 = [[CBMutableDescriptor alloc]initWithType: CBUUIDCharacteristicUserDescriptionStringUUID value:@"name"];
    [readwriteCharacteristic setDescriptors:@[readwriteCharacteristicDescription1]];
    
    //service1初始化并加入两个characteristics
    CBMutableService *service1 = [[CBMutableService alloc]initWithType:[CBUUID UUIDWithString:kBluetoottServiceUUID] primary:YES];
    
    [service1 setCharacteristics:@[self.notiyCharacteristic,readwriteCharacteristic]];
    

    //添加后就会调用代理的- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
    [_serverCM addService:service1];
}

/**
 *  停止服务
 */
- (void)stopService{
    [_serverCM stopAdvertising];
}

#pragma mark -数据发送
/**
 *  发送数据
 *
 *  @param sendData 要发送的数据 NSData类型
 */
- (void)sendData:(NSData *)msgData{
    BLEDataPack *mod=[[BLEDataPack alloc] initWithData:msgData];
    [dataPackList addObject:mod];
    
    //如果当前没有发送数据
    if (!sendingDataPack) {
        NSLog(@"peripheralManager 3");
        [self sendNextDataPack];
    }
}

/**
 * @breif 发送下一个数据
 */
- (void)sendNextDataPack{
    sendingDataPack = nil;
    if ([dataPackList count]>0) {
        sendingDataPack=[dataPackList objectAtIndex:0];
        [dataPackList removeObjectAtIndex:0];
        
        [self sendBLEDataPack];
    }
}

//循环发送数据
- (void)sendBLEDataPack{
    
    BOOL didSend=YES;
    while (didSend) {
        
        if (sendingDataPack) {
            if (!sendingDataPack.isFinished) {
                NSLog(@"发送分段数据");
                didSend=[self writeData:[sendingDataPack beginSendData]];
                
                if (!didSend) {
                    [sendingDataPack restoreLastData];
                }else{
                    [self handlerWritePartialData:sendingDataPack.currentData];
                }
            }
            
            if (!didSend) {
                return;
            }
            
            //表示数据全部发送完成
            if (sendingDataPack.isFinished) {
                //[self handlerWritePartialData:sendingDataPack.currentData];
                NSLog(@"发送完成");
                didSend=NO;
                [self sendNextDataPack];
            }
        }else{
            didSend=NO;
        }
    }

}

- (BOOL)writeData:(NSData *)subData{
    if (self.central&&subData&&[subData length]>0) {
       BOOL  didSend = [_serverCM updateValue:subData forCharacteristic:self.notiyCharacteristic onSubscribedCentrals:@[self.central]];
        if (didSend) {
            NSLog(@"发送成功");
        }else{
            //发送失败会走- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral方法，并调用sendBLEDataPack方法生新发送数据
            NSLog(@"发送失败");
        }
        
        return didSend;
    }
    
    return NO;
}

#pragma mark -私有方法
- (void)handlerWritePartialData:(NSData *)partialData{
    if (partialData&&[partialData length]>0) {
        //写入通知
        [[NSNotificationCenter defaultCenter] postNotificationName:kBLEPeripheralWritePartialDataNotification object:partialData];
        
        if (self.writeDataCompletedBlock) {
            self.writeDataCompletedBlock(partialData);
        }
    }
}


@end
