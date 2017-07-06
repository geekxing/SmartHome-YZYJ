/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BLEInfoCell.m
//  qks

#import "BLEInfoCell.h"
#import "BLEDeviceInfo.h"

@implementation BLEInfoCell {
    UILabel * title;
    UILabel * IDlabel;
    UILabel * ID;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createUI];
    }
    return self;
}

-(void)createUI {
    
    
    title= [[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.frame.size.width - 20, 20)];
    title.textColor = [UIColor blackColor];
    title.font = [UIFont systemFontOfSize:16];
    title.tag = 11;
    [self.contentView addSubview:title];
    
    
    IDlabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(title.frame), CGRectGetMaxY(title.frame) + 10, 40, CGRectGetHeight(title.frame))];
    IDlabel.textColor = [UIColor blackColor];
    IDlabel.text = @"UUID:";
    IDlabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:IDlabel];
    
    ID = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(IDlabel.frame) + 5, CGRectGetMinY(IDlabel.frame), [[UIScreen mainScreen] bounds].size.width - CGRectGetWidth(IDlabel.frame) - 25, CGRectGetHeight(IDlabel.frame))];
    ID.textColor = [UIColor blackColor];
    ID.font = [UIFont systemFontOfSize:12];
    ID.tag = 12;
    [self.contentView addSubview:ID];
    
}

-(void)setMod:(BLEDeviceInfo *)mod {
    _mod = mod;
    title.text = mod.peripheral.name;
    ID.text = [NSString stringWithFormat:@"%@",mod.peripheral.identifier.UUIDString];
}

@end
