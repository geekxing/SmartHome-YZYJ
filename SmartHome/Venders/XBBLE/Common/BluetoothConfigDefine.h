/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BluetoothConfigDefine.h
//  BlueDemo
//


#ifndef BluetoothConfigDefine_h
#define BluetoothConfigDefine_h

//蓝牙中心通知处理
#define kBluetoothStateChangedNotification          @"kBluetoothStateChangedNotification"  //表示蓝牙状态变更通知
#define kBluetoothConnectFinishedNotification       @"kBluetoothConnectFinishedNotification"  //表示蓝牙连接完成(包含连接失败)
#define kBluetoothDisConnectNotification            @"kBluetoothDisConnectNotification"  //表示蓝牙断开连接通知
#define kBluetoothScanCompletedNotification         @"kBluetoothScanCompletedNotification"  //表示蓝牙扫描完成

//蓝牙中心数据收/发通知
#define kBLEConnectorWritePartialDataNotification      @"kBLEConnectorWritePartialDataNotification" //发送蓝牙数据通知
#define kBLEConnectorReceivePartialDataNotification    @"kBLEConnectorReceivePartialDataNotification" //接收蓝牙数据通知

//外围数据收/发通知
#define kBLEPeripheralWritePartialDataNotification     @"kBLEPeripheralWritePartialDataNotification" //发送蓝牙数据通知
#define kBLEPeripheralReceivePartialDataNotification   @"kBLEPeripheralReceivePartialDataNotification" //接收蓝牙数据通知

typedef enum {
    BluetoothStateOpen=0,  //蓝牙打开状态
    BluetoothStateClose,   //蓝牙关闭状态
    BluetoothStateUnknown  //蓝牙未知状态
}BluetoothState;

//block
typedef void (^BLEStateChangedBlock) (BOOL isOpen);



//蓝牙外围服务配置
#define kBluetoottServiceUUID                  @"FFe0"   //服务器uuid，未使用。
#define kBluetoottNotiyCharacteristicUUID      @"FFe4"   //通知uuid
#define kBluetoottReadwriteCharacteristicUUID  @"FFe1"   //写入uuid

#endif /* BluetoothConfigDefine_h */
