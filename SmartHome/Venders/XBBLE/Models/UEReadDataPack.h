/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  UEReadDataPack.h
//  BlueDemo
//


#import <Foundation/Foundation.h>

@interface UEReadDataPack : NSObject

@property (nonatomic,assign) NSUInteger totalLen;
@property (nonatomic,assign) NSUInteger readTotalLen;
@property (nonatomic,assign) BOOL isTotalReadFinished;
@property (nonatomic,strong) NSMutableData *readTotalData;

@property (nonatomic,assign) NSUInteger bodyLen;
@property (nonatomic,assign) NSUInteger readBodyLen;
@property (nonatomic,strong) NSMutableData *readBodyData;
@property (nonatomic,assign) BOOL isBodyReadFinished;

@property (nonatomic,assign) BOOL isReadFinished;
@property (nonatomic,readonly) float progress;

@end
