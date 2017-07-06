/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BLEInfoManagerViewController.m
//  qks
//


#import "BLEInfoManagerViewController.h"
#import "SVProgressHUD.h"
#import "BLECentralManager.h"
#import "BLEInfoEditCell.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#define INTERVAL_KEYBOARD 90

#define BLE_SET_CODE_DEV_NAME 0xa1
#define BLE_SET_CODE_DEV_ID   0xa2
#define BLE_SET_CODE_WIFI_SSID 0xa3
#define BLE_SET_CODE_WIFI_PWD 0xa4
#define BLE_SET_CODE_SERV_IP 0xa5
#define BLE_SET_CODE_SERV_PORT 0xa6

@interface BLEInfoManagerViewController()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>


@property (nonatomic , copy) NSString * firInfo;
@property (nonatomic , copy) NSString * secInfo;


@end

@implementation BLEInfoManagerViewController {
    
    NSInteger     cellIndex;
    NSString    * btnTitle;
    UILabel     * wifiNameLabel;
    UITextField * wifiName;
    UITextField * wifiPwd;
    UIButton    * setting;
    UIButton    * next;
    
    UITableView * hideInfoTableView;
    NSArray * hideInfoDataSource;
    
}

-(void)viewWillDisappear:(BOOL)animated {
    
    [[BLECentralManager shareInstance] cancelAllConnect];
    
}

-(void)dealloc {
    
    [[BLECentralManager shareInstance] cancelAllConnect];
    
}


-(void)viewDidLoad {
    
    [super viewDidLoad];
    
    cellIndex = 0;
    _sendingDataModel=nil;
    _receiveDataModel=nil;
    
    [self createUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playBackValue:) name:kBLEConnectorReceivePartialDataNotification object:nil];
}

-(void)createUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    wifiNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 74, 60, 40)];
    wifiNameLabel.textColor = [UIColor blackColor];
    wifiNameLabel.numberOfLines = 0;
    wifiNameLabel.tag = 11;
    wifiNameLabel.font = [UIFont systemFontOfSize:14];
    wifiNameLabel.text = NSLocalizedString(@"Wifi Name", @"");
    [self.view addSubview:wifiNameLabel];
    
    wifiName = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(wifiNameLabel.frame) + 5, CGRectGetMidY(wifiNameLabel.frame) - 20, [[UIScreen mainScreen]bounds].size.width - CGRectGetWidth(wifiNameLabel.frame) - 25, 40)];
    wifiName.tag = 12;
    wifiName.borderStyle = UITextBorderStyleRoundedRect;
    wifiName.placeholder = NSLocalizedString(@"Enter Wifi Name", @"");
    NSString * getWifiName = [NSString stringWithFormat:@"%@",[self getWifiName]];
    if (getWifiName && ![getWifiName isEqualToString:@"nil"] && ![getWifiName isEqualToString:@"(null)"]) {
        wifiName.text = getWifiName;
    }
    wifiName.delegate = self;
    [self.view addSubview:wifiName];
    
    UILabel * wifiPwdLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(wifiNameLabel.frame), CGRectGetMaxY(wifiNameLabel.frame) + 10, CGRectGetWidth(wifiNameLabel.frame), CGRectGetHeight(wifiNameLabel.frame))];
    wifiPwdLabel.textColor = [UIColor blackColor];
    wifiPwdLabel.numberOfLines = 0;
    wifiPwdLabel.tag = 13;
    wifiPwdLabel.font = [UIFont systemFontOfSize:14];
    wifiPwdLabel.adjustsFontSizeToFitWidth = YES;
    wifiPwdLabel.minimumScaleFactor = 0.5;
    wifiPwdLabel.text = NSLocalizedString(@"Wifi Password", @"");
    [self.view addSubview:wifiPwdLabel];
    
    wifiPwd = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(wifiPwdLabel.frame) + 5, CGRectGetMidY(wifiPwdLabel.frame) - 20, [[UIScreen mainScreen]bounds].size.width - CGRectGetWidth(wifiNameLabel.frame) - 25, 40)];
    wifiPwd.tag = 14;
    wifiPwd.borderStyle = UITextBorderStyleRoundedRect;
    wifiPwd.placeholder = NSLocalizedString(@"Enter Wifi Password", @"");
    wifiName.delegate = self;
    [self.view addSubview:wifiPwd];
    
    setting = [[UIButton alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(wifiPwd.frame) + 10, self.view.frame.size.width - 30, 40)];
    setting.layer.cornerRadius = 8;
    setting.clipsToBounds = YES;
    setting.backgroundColor = [UIColor colorWithRed:((float)((0x2dc54c & 0xFF0000) >> 16))/255.0 green:((float)((0x2dc54c & 0xFF00) >> 8))/255.0 blue:((float)(0x2dc54c & 0xFF))/255.0 alpha:1.0];
    [setting setTitle:NSLocalizedString(@"set up",nil) forState:UIControlStateNormal];
    [setting addTarget:self action:@selector(setBLEInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setting];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (string.length == 0) return YES;//退格回删字符
    NSInteger existedLength = textField.text.length;
    NSInteger selectedLength = range.length;
    NSInteger replaceLength = string.length;
    if ( [string isEqualToString:@""] ) {
        return YES;
    }
    if ( textField.tag == 12 ) {
        if (existedLength - selectedLength + replaceLength > 18) {
            return NO;
        }
    }else if ( textField.tag == 14 ){
        if (existedLength - selectedLength + replaceLength > 22) {
            return NO;
        }
    }
    return YES;
}


-(void)playBackValue:(NSNotification *)notification {
    
    NSString * str = [NSString stringWithFormat:@"%@",notification.object];
    if ([str isEqualToString:@"<00>"]) {
        
        cellIndex ++;
        if (cellIndex == 2) {
            cellIndex = 0;
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"BLE_MODIFY_SUCESS",nil)];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSInteger index = [self.navigationController.childViewControllers indexOfObject:self];
                [self.navigationController popToViewController:self.navigationController.childViewControllers[index - 3] animated:YES];
            });
        }else if ( cellIndex == 1 ){
            [self sendText:_secInfo andScript:BLE_SET_CODE_WIFI_PWD];
        }
    }else if ([str isEqualToString:@"<01>"]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BLE_MODIFY_FAIL",nil)];
    }else if ([str isEqualToString:@"<02>"]) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BLE_MODIFY_FAIL",nil)];
    }
}

-(void)setBLEInfo:(UIButton *)btn {
    _firInfo = wifiName.text;
    _secInfo = wifiPwd.text;
    next.hidden = YES;
    [wifiName resignFirstResponder];
    [wifiPwd resignFirstResponder];
    [SVProgressHUD show];
    [self sendText:_firInfo andScript:BLE_SET_CODE_WIFI_SSID];
}

#pragma mark - 键盘显示事件 -
///键盘显示事件
- (void) keyboardWillShow:(NSNotification *)notification {
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGFloat offset = ( 20 + (cellIndex * 90) + INTERVAL_KEYBOARD) - (self.view.frame.size.height - kbHeight);//kbHeight + INTERVAL_KEYBOARD;
    
    // 取得键盘的动画时间，这样可以在视图上移的时候更连贯
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if (offset > 0) {
        
        [UIView animateWithDuration:duration animations:^{
            
            hideInfoTableView.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
            
        }];
        
    }else if (offset < 0) {
        
        [UIView animateWithDuration:duration animations:^{
            
            hideInfoTableView.frame = CGRectMake(0.0f, 0, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
}

///键盘消失事件
- (void) keyboardWillHide:(NSNotification *)notify {
    // 键盘动画时间
    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //视图下沉恢复原状
    [UIView animateWithDuration:duration animations:^{
        hideInfoTableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    }];
}


#pragma mark -数据发送处理

//发送文本
- (void)sendText:(NSString *)info andScript:(NSInteger)script{
    
    NSString * content = info;
    if ( [content length] == 0 ) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"no_empty",nil)];
        return;
    }

    if ( [BLECentralManager shareInstance].bluetoothState != BluetoothStateOpen)  {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ble_donot_open",nil)];
        return;
    }

    if ( ![[BLECentralManager shareInstance].getFirstConnector isConnected] ) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"ble_dis_connect",nil)];
        return;
    }
    NSData * sendData=[info dataUsingEncoding:NSUTF8StringEncoding];

    UEBaseData * mod=[[UEBaseData alloc] init];
    mod.packetId=script;
    mod.extStr=nil;
    [mod.bodyData appendData:sendData];
    NSLog(@"%@",mod.encodeData);
    //发送
    [[BLECentralManager shareInstance].getFirstConnector sendData:[mod encodeData]];
}


#pragma mark -收发数据事件
- (void)beginDelegate{
    
    //发送数据处理(或者监听通知kBLEConnectorWritePartialDataNotification)
    [BLECentralManager shareInstance].getFirstConnector.writeDataCompletedBlock=^(NSData *partialData){
        [self handlerWriteData:partialData];
    };
    
    //接收数据处理(或者监听通知kBLEConnectorReceivePartialDataNotification)
    [BLECentralManager shareInstance].getFirstConnector.receiveDataCompletedBlock=^(NSData *receiveData){
        [self handlerReceiveData:receiveData];
    };
    
}
#pragma mark -发送数据处理

/**
 * 处理发送的数据
 *
 *
 */
- (void)handlerWriteData:(NSData *)writeData{
    if (_sendingDataModel==nil) {
        //解析发送的数据
        _sendingDataModel=[UEBaseData decodeWithData:writeData];
        
        //全部发送完成
        if (_sendingDataModel&&[_sendingDataModel isFinished]) {
            _sendingDataModel=nil;
        }
        
        return;
    }
    
    //添加未发送完的数据
    if (_sendingDataModel) {
        [_sendingDataModel addReadData:writeData];
    }
    
    
    if (_sendingDataModel&&_sendingDataModel.packetId==2) {
    }
    
    //全部发送完成
    if (_sendingDataModel&&[_sendingDataModel isFinished]) {
        _sendingDataModel=nil;
    }
}


#pragma mark - 数据接收处理

/**
 *  处理接收的数据
 *
 *
 */
- (void)handlerReceiveData:(NSData *)receiveData{
    
    if (!_receiveDataModel) {
        //解析收到的数据
        _receiveDataModel=[UEBaseData decodeWithData:receiveData];
        if (_receiveDataModel == nil) {
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BLE_MODIFY_FAIL",nil)];
        }
        return;
    }
    
    if (_receiveDataModel) { //添加未接收完的数据
        [_receiveDataModel addReadData:receiveData];
    }
    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return hideInfoDataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BLEInfoEditCell * cell = [tableView dequeueReusableCellWithIdentifier:@"CellForEditBLE"];
    if (!cell) {
        cell = [[BLEInfoEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellForEditBLE"];
    }
    cell.title = hideInfoDataSource[indexPath.row];
    
    cell.tfBecomeFirstResponder = ^{
        cellIndex = indexPath.row;
    };
    
    cell.sendBLEManageInfo = ^(NSString * bleInfo) {
        
        [self sendText:bleInfo andScript:indexPath.row + 1];
        
    };
    
    return cell;
    
}
-(NSString *)getWifiName
{
    NSString *wifi = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString * interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            NSLog(@"network info -> %@", networkInfo);
            wifi = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifi;
}

@end
