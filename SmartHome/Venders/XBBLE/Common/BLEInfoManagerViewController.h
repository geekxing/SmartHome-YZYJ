/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BLEInfoManagerViewController.h
//  qks
//


#import <UIKit/UIKit.h>
#import "UEBaseData.h"

@interface BLEInfoManagerViewController : UIViewController {
    
    __block UEBaseData *_sendingDataModel;   // 发送数据
    __block UEBaseData *_receiveDataModel;   // 接收数据
    
}

@property (nonatomic , assign) NSInteger numOfVCNeedPop;

@property (nonatomic , copy) void (^setBLEFinished)();

@property (nonatomic , copy) NSDictionary * targetDevInfo;

@end
//a
