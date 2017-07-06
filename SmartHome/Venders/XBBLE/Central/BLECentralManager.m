/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BluetoothClientManager.m
//  BlueDemo


#import "BLECentralManager.h"
#import "SmartHome-Swift.h"

@interface BLECentralManager ()<CBCentralManagerDelegate>{
    
    CBCentralManager *_clientCM;
}
@property (nonatomic,strong) NSMutableArray *connetorList;//多个连接对象
@property (nonatomic,strong) NSMutableArray *scanBlueList;//扫描多个对象
@end

@implementation BLECentralManager

@synthesize clientmanager=_clientCM;

+ (BLECentralManager *)shareInstance
{
    static dispatch_once_t pred = 0;
    __strong static BLECentralManager *_sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    return _sharedObject;
}

- (id)init{
    
    if (self=[super init]) {
        
        
        self.bluetoothState=BluetoothStateUnknown;
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerOptionShowPowerAlertKey, nil];
        _clientCM = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
        self.connetorList=[[NSMutableArray alloc] init];
        self.scanBlueList=[[NSMutableArray alloc] init];
    }
    return self;
}

/**
 *  获取第一个连接对象
 *
 *  @return
 */
- (BLEConnector *)getFirstConnector{
    if (self.connetorList.count >0) {
        return [self.connetorList objectAtIndex:0];
    }
    return nil;
}

/**
 *  开始扫描
 */
-(void)startScan{
    
    [self.scanBlueList removeAllObjects];
    
    if(self.bluetoothState==BluetoothStateOpen)
    {
        [self updateLog:@"开始扫描"];
        [_clientCM scanForPeripheralsWithServices:nil options:nil];
    }
    else
    {
        //弹框提示，请去系统中打开蓝牙
        LGAlertView *alert =
        [LGAlertView alertViewWithTitle:NSLocalizedString(@"Please open the Bluetooth on system settings", @"请到系统设置中打开蓝牙")
                                message:nil
                                  style:LGAlertViewStyleAlert
                           buttonTitles:nil
                      cancelButtonTitle:NSLocalizedString(@"DONE", @"")
                 destructiveButtonTitle:nil
                               delegate:nil];
        [alert showAnimated];
    }
    
    
}

/**
 *  停止扫描
 */
-(void)stopScan{
    [self.scanBlueList removeAllObjects];
    
    [self updateLog:@"停止扫描"];
    [_clientCM stopScan];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startScan) object:nil];
}


/**
 *  连接
 */
-(void)beginConnectWithPeripheral:(CBPeripheral *)peripheral
{
    
//    [_clientCM connectPeripheral:peripheral options:nil];
    [_clientCM connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
}

-(void)beginConnectWithPeripheral:(CBPeripheral *)peripheral connectCompleted:(void (^)(CBPeripheral *peripheral,BOOL success,NSError *error))completed{
    [_clientCM connectPeripheral:peripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    self.BluetoothConnectFinishedBlock=completed;
}

/**
 *  取消连接
 */
-(void)cancelConnectWithPeripheral:(CBPeripheral *)peripheral
{
    NSArray *arr=[self.connetorList valueForKeyPath:@"ftPeripheral"];
    if (arr&&[arr count]>0) {
        [self.connetorList removeObject:[arr objectAtIndex:0]];
    }
    [_clientCM cancelPeripheralConnection:peripheral];
    
}

- (void)cancelAllConnect{
    
    for (BLEConnector *item in self.connetorList) {
        [_clientCM cancelPeripheralConnection:item.ftPeripheral];
    }
    [self.connetorList removeAllObjects];
}

#pragma mark -CBCentralManagerDelegate Methods
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{

    //蓝牙状态
    self.bluetoothState=central.state==CBCentralManagerStatePoweredOn?BluetoothStateOpen:BluetoothStateClose;
    
    if (self.BluetoothInitCompletedBlock) {
        self.BluetoothInitCompletedBlock(central.state==CBCentralManagerStatePoweredOn?YES:NO);
    }
    
    //如果蓝牙打开则进行扫描
    if (self.bluetoothState==BluetoothStateOpen) {
        [self startScan]; //开始扫描
    }
    
    BOOL isOpen=self.bluetoothState==BluetoothStateOpen?YES:NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothStateChangedNotification object:central userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:isOpen],@"state", nil]];
}

/*
 当扫描时会执行这里
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
        NSLog(@"当扫描到设备:%@",aPeripheral);
    
        BLEDeviceInfo *mod=[[BLEDeviceInfo alloc] init];
        mod.peripheral=aPeripheral;
        mod.advertisementData=advertisementData;
        mod.rssi=RSSI;
        
        //添加扫描
        [self addBluetoothWithModel:mod];
        
        
}

/*
 * 已连接到外围设备
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"periphral connected%@", peripheral);
    //停止扫描
    [self stopScan];
    
    //连接成功处理
    [self addPeripheral:peripheral];
    
    if (self.BluetoothConnectFinishedBlock) {
        self.BluetoothConnectFinishedBlock(peripheral,YES,nil);
    }
    
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:peripheral,@"peripheral",[NSNumber numberWithBool:YES],@"success",@"",@"error", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothConnectFinishedNotification object:nil userInfo:dic];
}
/*
 * 连接到外围设备失败
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    [self cleanupWithPeripheral:peripheral];
    
    if (self.BluetoothConnectFinishedBlock) {
        self.BluetoothConnectFinishedBlock(peripheral,NO,error);
    }
    
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:peripheral,@"peripheral",[NSNumber numberWithBool:NO],@"success",error.description,@"error", nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothConnectFinishedNotification object:nil userInfo:dic];
}
/*
 * 已断开从机的连接
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    //连接断开
    [self cancelConnectWithPeripheral:peripheral];
    
    if (self.BluetoothDisConnectBlock) {
        self.BluetoothDisConnectBlock(peripheral,error);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothDisConnectNotification object:nil];
}

#pragma mark -
#pragma mark - retrieveConnected
- (void) centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary *)state
{
    NSArray *peripherals = state[CBCentralManagerRestoredStatePeripheralsKey];
    
    CBPeripheral *peripheral;
    
    /* Add to list. */
    for (peripheral in peripherals) {
        [self beginConnectWithPeripheral:peripheral];
    }
}
- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
    CBPeripheral *peripheral;
    
    /* Add to list. */
    for (peripheral in peripherals) {
        if (peripheral) {
            [self beginConnectWithPeripheral:peripheral];
        }
    }
}
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    CBPeripheral *peripheral;
    
    /* Add to list. */
    for (peripheral in peripherals) {
        [self beginConnectWithPeripheral:peripheral];
    }
}

#pragma mark - 私有方法
- (void)addPeripheral:(CBPeripheral *)peripheral{
    NSArray *arr=[self.connetorList valueForKeyPath:@"ftPeripheral"];
    if (arr&&[arr count]>0&&[arr containsObject:peripheral]) {
        return;
    }
    BLEConnector *ft=[[BLEConnector alloc] init];
//    BLEConnector *ft = [BLEConnector shareInstance];
    ft.ftPeripheral=peripheral;
    [self.connetorList addObject:ft];
}

- (void)cleanupWithPeripheral:(CBPeripheral *)peripheral{
    // See if we are subscribed to a characteristic on the peripheral
    if (peripheral.services != nil) {
        for (CBService *service in peripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    if (characteristic.isNotifying) {
                        // It is notifying, so unsubscribe
                        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
                        
                        // And we're done.
                        //return;
                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self cancelConnectWithPeripheral:peripheral];
}
/**
 *  添加扫描到的设备
 *
 *  @param mod 设备
 */
- (void)addBluetoothWithModel:(BLEDeviceInfo *)mod{
    
    NSArray *arr=[self.scanBlueList valueForKeyPath:@"peripheral"];
    
    BOOL isExists=NO;
    if (arr&&[arr count]>0) {
        
        if ([arr containsObject:mod.peripheral]) {
            isExists=YES;
        }
    }
    
    if (!isExists) {
        [self.scanBlueList addObject:mod];
        
        if (self.BluetoothScanDeviceBlock) {
            self.BluetoothScanDeviceBlock(mod);
        }
        
        if (self.BluetoothScanCompletedBlock) {
            self.BluetoothScanCompletedBlock(self.scanBlueList);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kBluetoothScanCompletedNotification object:self.scanBlueList];
    }
    
}
-(void)updateLog:(NSString *)s
{
    //用回NSLog，
    //NSLog(@"%@",s );
}

@end
