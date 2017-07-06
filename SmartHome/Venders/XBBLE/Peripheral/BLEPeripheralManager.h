/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BluetoothServerManager.h
//  BlueDemo
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BluetoothConfigDefine.h"

//接收数据block
typedef void (^BLEPeripheralReceivePartialDataBlock) (NSData *receiveData);
//发送数据block
typedef void (^BLEPeripheralWritePartialDataBlock)(NSData *writeData);

@interface BLEPeripheralManager : NSObject

/**
 *  外围对象
 */
@property (nonatomic,readonly) CBPeripheralManager *serverManager;

/**
 *  蓝牙当前状态
 */
@property (nonatomic,assign) BluetoothState bluetoothState;

/**
 * 接收数据block
 */
@property (nonatomic,copy)  BLEPeripheralReceivePartialDataBlock   receiveDataCompletedBlock;

/**
 * 发送数据block
 */
@property (nonatomic,copy)  BLEPeripheralWritePartialDataBlock     writeDataCompletedBlock;


+ (BLEPeripheralManager *)shareInstance;

/**
 *  添加服务
 */
- (void)startService;

/**
 *  停止服务
 */
- (void)stopService;

/**
 *  发送数据
 *
 *  @param msgData 要发送的数据 NSData类型
 */
- (void)sendData:(NSData *)msgData;

@end
