//
//  CBCentralViewController.m
//  qks
//
//  Created by yfone on 16/6/14.
//  Copyright © 2016年 Ivan. All rights reserved.
//

#import "CBCentralViewController.h"

#import "BLECentralManager.h"
#import "ActionSheetHelper.h"
#import "SVProgressHUD.h"
#import "BLEInfoManagerViewController.h"
#import "BLEInfoCell.h"
#import "SmartHome-Swift.h"

@interface CBCentralViewController()<UITableViewDelegate,UITableViewDataSource>

@end
@implementation CBCentralViewController {
    
    UITableView * myTableView;
    NSMutableArray * dataSource;
    NSInteger _currentIndex;
    BOOL _isShowing;
    NSTimer * timer;
    
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver: self ];
}
-(void)viewWillDisappear:(BOOL)animated {
    
}
-(void)viewDidAppear:(BOOL)animated {
    
//    BLECentralManager * manager = [BLECentralManager shareInstance];
//    [manager cancelAllConnect];  
//    if (manager.bluetoothState == BluetoothStateOpen) {
//        [manager startScan];
//    }else if (manager.bluetoothState == BluetoothStateUnknown) {
//        NSLog(@"蓝牙状态未知");
//    }else if (manager.bluetoothState == BluetoothStateClose) {
//        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"hk_ble_not_reachable",nil)];
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentIndex=-1;
	_isShowing = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addData:) name:kBluetoothScanCompletedNotification object:nil];
    //数据初始化
    [self dataInit];
    //扫描蓝牙
    BLECentralManager * manager = [BLECentralManager shareInstance];
    [manager startScan];
    NSLog(@"%u",manager.bluetoothState);
    if (manager.bluetoothState == BluetoothStateOpen) {
        [manager startScan];
    }else if (manager.bluetoothState == BluetoothStateUnknown) {
        NSLog(@"蓝牙状态未知");
    }else if (manager.bluetoothState == BluetoothStateClose) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ble_not_reachable",nil)];
    }
    //蓝牙状态
    [BLECentralManager shareInstance].BluetoothInitCompletedBlock=^(BOOL isCan){
        if (!isCan) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ble_not_reachable",nil)];
        }
    };
    //表示蓝牙已连接
    [BLECentralManager shareInstance].BluetoothConnectFinishedBlock=^(CBPeripheral *peripheral,BOOL success,NSError *error){
        if (success) {
            timer = [[NSTimer alloc] initWithFireDate:[NSDate distantFuture] interval:10
                                               target:self
                                             selector:@selector(cancelCurrentConnect)
                                             userInfo:nil
                                              repeats:NO];
            
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (timer) {
                    [timer setFireDate:[NSDate distantPast]];
                }
            });
        }else{
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ble_connect_fail",nil)];
            NSLog(@"蓝牙连接失败=%@",error);
        }
    };
    //断开连接
    [BLECentralManager shareInstance].BluetoothDisConnectBlock=^(CBPeripheral *peripheral,NSError *error){
        NSLog(@"连接断开=%@,end tiem =%@",peripheral,[NSDate date]);
        NSLog(@"连接断开原因=%@",error.description);
    };
    [self createTableView];
}

-(void)cancelCurrentConnect {
    
    if (_isShowing == YES) {
        
        [[BLECentralManager shareInstance] cancelAllConnect];
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ble_connect_out_of_time",nil)];
    }
    
}

-(void)getTargetDev:(NSNotification *)notification {

    [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ble_connect_success",nil)];
    //连接成功后跳转到新界面
    
}

-(void)createTableView {
    
    myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [self.view addSubview: myTableView ];
    
}


-(void)addData:(NSNotification *)notification {
    
    NSArray * arr = notification.object;
    if (!dataSource) {
        
        dataSource = [[NSMutableArray alloc] init];
        
    }else if (dataSource.count != 0 ) {
        
        [dataSource removeAllObjects];
        
    }
    [dataSource addObjectsFromArray:arr];
    [myTableView reloadData];
    
    NSInteger index = [self checkIfBindingDeviceAppear:dataSource];
    if (index != NSNotFound) {
        [self connectBLEWhenTap:[NSIndexPath indexPathForRow:index inSection:0]];
    }
}

- (NSInteger )checkIfBindingDeviceAppear:(NSArray*)devices {

    NSString *sn = [[XBUserManager shared].loginUser Device].firstObject;
    __block NSInteger indexOfMyDevice = NSNotFound;
    [devices enumerateObjectsUsingBlock:^(BLEDeviceInfo* obj, NSUInteger idx, BOOL * stop) {
        NSString *nameLast8 = [obj.peripheral.name substringFromIndex:obj.peripheral.name.length - 8];
        NSString *snLast8  = [sn substringFromIndex:sn.length - 8];
        if ([nameLast8 isEqualToString:snLast8]) {
            indexOfMyDevice = idx;
            *stop = YES;
        }
    }];
    return indexOfMyDevice;
    
}

- (void)connectBLEWhenTap:(NSIndexPath*)indexPath {
    _currentIndex=indexPath.row;
    if (_currentIndex >= 0 && _currentIndex < dataSource.count) {
        BLEDeviceInfo *info = [dataSource objectAtIndex:_currentIndex];
        NSLog(@"%@",info);
        //蓝牙连接处理
        [[BLECentralManager shareInstance] beginConnectWithPeripheral:info.peripheral connectCompleted:^(CBPeripheral *peripheral, BOOL success, NSError *error) {
            [SVProgressHUD show];
            if (success) {
                [SVProgressHUD showSuccessWithStatus:@"ble_connect_success"];
                BLEInfoManagerViewController * bleInfoManager = [[BLEInfoManagerViewController alloc] init];
                bleInfoManager.numOfVCNeedPop = 2;
                [self.navigationController pushViewController:bleInfoManager animated:YES];
            }else{
                [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ble_connect_fail",nil)];
                NSLog(@"蓝牙连接失败=%@",error);
            }
        }];
    }
    _currentIndex = -1;
}

#pragma mark - 数据初始化

/**
 *  数据初始化
 */
- (void)dataInit{
    
    if (!dataSource) {
        dataSource = [[NSMutableArray alloc] init];
    } 
    //重连
    
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"reconnect", @"")
                                                                            style:UIBarButtonItemStylePlain
                                                                           target:self
                                                                           action:@selector(resetStartScan)];
    
    //失去焦点
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResponed:)];
    tapGr.cancelsTouchesInView=NO;
    [self.view addGestureRecognizer:tapGr];
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BLEInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[BLEInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    BLEDeviceInfo *info =dataSource[indexPath.row];
    cell.mod = info;
    cell.accessoryType=_currentIndex==indexPath.row?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self connectBLEWhenTap:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -其它事件

//失去焦点
- (void)textFieldResponed:(UITapGestureRecognizer*)tapGr{
    [self.view endEditing:YES];
}

//重写返回事件
- (BOOL)isNavigationBack{
    [[BLECentralManager shareInstance] cancelAllConnect];
    return YES;
}

//重连
- (void)resetStartScan{
    [[BLECentralManager shareInstance] cancelAllConnect];
    [[BLECentralManager shareInstance] startScan];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

