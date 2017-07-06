/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BLEInfoCell.h
//  qks
//

#import <UIKit/UIKit.h>

@class BLEDeviceInfo;

@interface BLEInfoCell : UITableViewCell

@property (nonatomic,copy) BLEDeviceInfo * mod;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@end
