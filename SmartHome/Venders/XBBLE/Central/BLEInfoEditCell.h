/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BLEInfoEditCell.h
//  qks
//


#import <UIKit/UIKit.h>

@interface BLEInfoEditCell : UITableViewCell

@property (nonatomic , copy) NSString * title;

@property (nonatomic , copy) void (^sendBLEManageInfo)(NSString * info);

@property (nonatomic , copy) void (^tfBecomeFirstResponder)();



@end
