/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BLEDataPack.h


#import <Foundation/Foundation.h>

#define QD_BLE_SEND_MAX_LEN  32  //蓝牙支持的最大发送包大小

/**
 * 数据发送处理
 */
@interface BLEDataPack : NSObject{
    
    NSInteger _currentIndex; //当前发送数据的索引
    NSInteger _prevIndex;//前一次发送数据的索引
}

/**
 *  需要发送的数据
 */
@property (nonatomic,strong) NSData *sendData;

/**
 *  当前发送的分段数据
 */
@property (nonatomic,strong) NSData *currentData;

/**
 *  发送是否完成
 */
@property (nonatomic,assign) BOOL isFinished;


- (id)initWithData:(NSData *)msgData;

/**
 *  取得分段发送数据
 *
 *  @return data
 */
- (NSData *)beginSendData;

/**
 *  复原前一次数据
 */
- (void)restoreLastData;

@end
