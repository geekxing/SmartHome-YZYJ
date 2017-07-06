/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BluetoothClientManager.h


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDeviceInfo.h"
#import "BLEConnector.h"
#import "BluetoothConfigDefine.h"

typedef void (^BLECentralDeviceScanBlock) (BLEDeviceInfo *device);
typedef void (^BLECentralDeviceScanCompletedBlock) (NSArray *devices);
typedef void (^BLECentralConnectedCompletedBlock) (CBPeripheral *peripheral,BOOL success,NSError *error);
typedef void (^BLECentralDisconnectBlock) (CBPeripheral *peripheral,NSError *error);


@interface BLECentralManager : NSObject

/**
 *  蓝牙当前状态
 */
@property (nonatomic,assign) BluetoothState bluetoothState;


/**
 *  传入需要扫描的目标mac
 */
@property (nonatomic , copy) NSString * targetMac;


/**
 *  中心对象
 */
@property (nonatomic,readonly) CBCentralManager *clientmanager;


/**
 *  蓝牙是否初始化完成(初始化完成可扫描)
 */
@property (nonatomic,copy) void (^BluetoothInitCompletedBlock) (BOOL isCompleted);

/**
 *  扫描完成回调
 */
@property (nonatomic,copy) void (^BluetoothScanDeviceBlock) (BLEDeviceInfo *info);

/**
 *  扫描到多个连接设备 (devices是BluetoothInfo对象集合)
 */
@property (nonatomic,copy) void (^BluetoothScanCompletedBlock) (NSArray *devices);

/**
 *  连接成功或失败回调
 */
@property (nonatomic,copy) void (^BluetoothConnectFinishedBlock) (CBPeripheral *peripheral,BOOL success,NSError *error);

/**
 *  断开连接回调
 */
@property (nonatomic,copy) void (^BluetoothDisConnectBlock) (CBPeripheral *peripheral,NSError *error);


+ (BLECentralManager *)shareInstance;

/**
 *  获取第一个连接对象
 *
 *  @return 连接对象
 */
- (BLEConnector *)getFirstConnector;

/**
 *  开始扫描
 */
-(void)startScan;

/**
 *  停止扫描
 */
-(void)stopScan;

/**
 *  连接
 */
-(void)beginConnectWithPeripheral:(CBPeripheral *)peripheral;
-(void)beginConnectWithPeripheral:(CBPeripheral *)peripheral connectCompleted:(void (^)(CBPeripheral *peripheral,BOOL success,NSError *error))completed;

/**
 *  取消连接
 */
-(void)cancelConnectWithPeripheral:(CBPeripheral *)peripheral;

/**
 *  取消所有连接
 */
- (void)cancelAllConnect;

@end
