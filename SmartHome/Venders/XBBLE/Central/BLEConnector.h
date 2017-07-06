/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BLEConnector.h
//  BlueDemo
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEDataPack.h"


//接收数据block
typedef void (^FTConnectorReceivePartialDataBlock)(NSData *receiveData);
//发送数据block
typedef void (^FTConnectorWritePartialDataBlock)(NSData *writeData);

/**
 *  表示一个连接对象
 */
@interface BLEConnector : NSObject{
    
    NSMutableArray* dataPackList; ///< 待发送报文列表
    BLEDataPack* sendingDataPack; ///<! 当前正在发送报文
}

@property (nonatomic,strong) CBPeripheral *ftPeripheral;
//+ (BLEConnector *)shareInstance;
/**
 *  接收数据block
 */
@property (nonatomic,copy) FTConnectorReceivePartialDataBlock receiveDataCompletedBlock;

/**
 *  发送数据block
 */
@property (nonatomic,copy) FTConnectorWritePartialDataBlock writeDataCompletedBlock;

@property (nonatomic , strong) CBCharacteristic * notifiCharacteristic;
@property (nonatomic , strong) CBCharacteristic * writeCharacteristic;
/**
 *  表示是否已连接
 *
 *  @return 结果
 */
- (BOOL)isConnected;


/**
 *  发送文本内容
 *
 *  @param message 消息
 */
- (void)sendMessage:(NSString *)message;

/**
 *  发送数据
 *
 *  @param msgData 要发送的数据 NSData类型
 */
- (void)sendData:(NSData *)msgData;

- (void)writeData:(NSData *)subData;

@end
