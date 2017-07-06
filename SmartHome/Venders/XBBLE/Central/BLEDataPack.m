/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BLEDataPack.m


#import "BLEDataPack.h"

@implementation BLEDataPack

- (id)init{
    
    if (self=[super init]) {
        
        _currentIndex=0;
        _prevIndex=0;
        self.isFinished=NO;
    }
    return self;
}

- (id)initWithData:(NSData *)msgData{
    
    if (self=[super init]) {
        self.sendData=msgData;
        
        NSLog(@"send total data len =%lu",(unsigned long)msgData.length);
    }
    return self;
}

- (NSData *)beginSendData{
    
    if (self.isFinished) {
        return nil;
    }
    
    if (self.sendData==nil||[self.sendData length]==0) {
        self.isFinished=YES;
        return nil;
    }
    
    NSString *rangeStr=nil;
    NSData *subData=nil;
    
    _prevIndex=_currentIndex;
    
    // 预加 最大包长度，如果依然小于总数据长度，可以取最大包数据大小
    if ((_currentIndex + QD_BLE_SEND_MAX_LEN) < [self.sendData length]) {
        rangeStr = [NSString stringWithFormat:@"%li,%i", (long)_currentIndex, QD_BLE_SEND_MAX_LEN];
        subData = [self.sendData subdataWithRange:NSRangeFromString(rangeStr)];
        _currentIndex += QD_BLE_SEND_MAX_LEN;
    }
    else {
        rangeStr = [NSString stringWithFormat:@"%li,%i", (long)_currentIndex, (int)([self.sendData length] - _currentIndex)];
        subData = [self.sendData subdataWithRange:NSRangeFromString(rangeStr)];
        _currentIndex += QD_BLE_SEND_MAX_LEN;
        self.isFinished=YES;
    }
    
    self.currentData=subData;
    
    return subData;
}
/**
 *  复原前一次数据
 */
- (void)restoreLastData{
    self.isFinished=NO;
    _currentIndex=_prevIndex;
}
@end
