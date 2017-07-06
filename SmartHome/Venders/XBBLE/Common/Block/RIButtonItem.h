/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  RIButtonItem.h

#import <Foundation/Foundation.h>

@interface RIButtonItem : NSObject
{
    NSString *label;
    void (^action)();
}
@property (retain, nonatomic) NSString *label;
@property (copy, nonatomic) void (^action)();
+(id)item;
+(id)itemWithLabel:(NSString *)inLabel;
@end

