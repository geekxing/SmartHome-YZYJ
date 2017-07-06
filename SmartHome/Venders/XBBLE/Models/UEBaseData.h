/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  UEBaseData.h
//  BlueDemo
//


#import <Foundation/Foundation.h>

@interface UEBaseData : NSObject

@property (nonatomic,assign) NSUInteger      packetId; ///< 指令码
@property (nonatomic,strong) NSString        *extStr; ///<! 扩展字段
@property (nonatomic,strong) NSMutableData   *bodyData; ///<! body数据

/**
 *  解码处理
 *
 *  @param characteristicValue 需要解码的数据
 *
 *  @return any
 */
- (id)initWithData:(NSData *)characteristicValue;

/**
 *  蓝牙解码处理
 *
 *  @param characteristicValue 需要解码的数据
 *
 *  @return any
 */
+ (id)decodeWithData:(NSData *)characteristicValue;


/**
 *  蓝牙编码处理
 *
 *  @return data
 */
- (NSData *)encodeData;

/**
 *  添加接收或者发送数据内容
 *
 *  @param data 数据内容
 *
 */
- (void)addReadData:(NSData *)data;

/**
 *  取得扩展内容
 *
 *  @return fileExt
 */
- (NSString *)getExtString;

/**
 *  取得发送或者接收进度
 *
 *  @return float
 */
- (float)progress;

/**
 *  接收或者发送是否完成
 *
 *  @return bool
 */
- (BOOL)isFinished;

/**
 *  取得保存的文件
 *
 *  @return string
 */
- (NSString *)getCacheFilePath;

/*****************************辅助方法************************************/

/**
 * @brief 读取1个byte,未判断data的数据长度(读取指令码)
 * @return 字节
 */
+ (NSUInteger)readByte:(NSData *)data;

/**
 * @brief 读取2个byte,未判断data的数据长度(读取扩展长度)
 * @return 字节
 */
+ (NSUInteger)readShort:(NSData *)data;

/**
 * @brief 读取4个byte,未判断data的数据长度(读取Body数据的长度)
 * @return 字节
 */
+ (NSUInteger)readInt:(NSData *)data;

/**
 * @brief 读取2+N个byte,未判断data的数据长度(读取扩展字段)
 * @return 字符串
 */
+ (NSString*)readString:(NSData *)data;

+ (void)writeByte:(NSMutableData *)data value:(NSUInteger)aValue;
+ (void)writeShort:(NSMutableData *)data value:(NSUInteger)aValue;
+ (void)writeInt:(NSMutableData *)data value:(NSUInteger)aValue;
+ (void)writetring:(NSMutableData *)data str:(NSString*)aStr;


@end

/**
 
 指令码            1个字节
 扩展长度          2个字节
 Body数据的长度    4个字节
 
**/
