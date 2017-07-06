/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BluetoothInfo.m
//  BlueDemo
//


#import "BLEDeviceInfo.h"

@implementation BLEDeviceInfo

- (NSString *)getBluetoothName{
    
    //这里还可以获取设备的一个广播名称 NSString *CBName=[advertisementData valueForKeyPath:CBAdvertisementDataLocalNameKey]; 这两个名称一般是不一样的

    //NSString *CBName=[self.advertisementData valueForKeyPath:CBAdvertisementDataLocalNameKey];
    
    if (self.advertisementData&&[self.advertisementData.allKeys containsObject:@"kCBAdvDataLocalName"]) {
        
        return [self.advertisementData objectForKey:@"kCBAdvDataLocalName"];
    }
    
    return self.peripheral.name;
}

@end
