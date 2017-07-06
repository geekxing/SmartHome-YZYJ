/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BLEInfoEditCell.m
//  qks
//


#import "BLEInfoEditCell.h"
#define Screen_Scale [[UIScreen mainScreen]bounds].size.width/375
@interface BLEInfoEditCell()<UITextFieldDelegate>

@end

@implementation BLEInfoEditCell {
    
    NSString * btnTitle;
    UILabel * titleLabel;
    
    
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
    
    
    titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 60, 40)];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.numberOfLines = 0;
    titleLabel.tag = 11;
    titleLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:titleLabel];

    UITextField * textField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame) + 5, CGRectGetMidY(titleLabel.frame) - 20, [[UIScreen mainScreen]bounds].size.width - 150, 40)];
    textField.tag = 12;
    textField.delegate = self;
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.placeholder = @"输入信息";
    
    [self.contentView addSubview:textField];
    
    UIButton * setting = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(textField.frame) + 10, 10, 60, 40)];
    setting.layer.cornerRadius = 5;
    [setting setBackgroundColor:[UIColor colorWithRed:((float)((0x2dc54c & 0xFF0000) >> 16))/255.0 green:((float)((0x2dc54c & 0xFF00) >> 8))/255.0 blue:((float)(0x2dc54c & 0xFF))/255.0 alpha:1.0]];
    [setting addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [setting setTitle:NSLocalizedString(@"control",nil) forState:UIControlStateNormal];
    [self.contentView addSubview:setting];
    
}

-(void)buttonClicked:(UIButton *)button {
    
    UITextField * tf = (id)[self.contentView viewWithTag:12];
    [tf resignFirstResponder];
    if (self.sendBLEManageInfo) {
        _sendBLEManageInfo(tf.text);
    }
    
}

- (void)textFieldDidChange:(UITextField *)textField
{
    NSData * data = [textField.text dataUsingEncoding:NSUTF8StringEncoding];
    if (data.length > 18) {
        textField.text = [textField.text substringToIndex:18];
    }
    
}

-(void)setTitle:(NSString *)title {
    titleLabel.text = title;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (self.tfBecomeFirstResponder) {
        _tfBecomeFirstResponder();
    }
    
}
-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSString * info = textField.text;
    if (self.sendBLEManageInfo) {
        _sendBLEManageInfo(info);
    }
    
}

@end
