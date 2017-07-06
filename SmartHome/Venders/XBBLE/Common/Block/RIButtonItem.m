/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  RIButtonItem.m


#import "RIButtonItem.h"

@implementation RIButtonItem
@synthesize label;
@synthesize action;

+(id)item
{
    return [self new];
}

+(id)itemWithLabel:(NSString *)inLabel
{
    RIButtonItem *newItem = [self item];
    [newItem setLabel:inLabel];
    return newItem;
}

@end

