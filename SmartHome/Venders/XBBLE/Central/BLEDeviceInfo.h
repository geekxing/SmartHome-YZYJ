/************************************************************************/
/*                      万沣信息   版权所有                             */
/*                      未经许可   不得盗用                             */
/************************************************************************/
//
//  BluetoothInfo.h
//  BlueDemo
//


#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEDeviceInfo : NSObject

@property (nonatomic,strong) CBPeripheral *peripheral;
@property (nonatomic,strong) NSDictionary *advertisementData;
@property (nonatomic,strong) NSNumber *rssi;
@property (nonatomic,strong) NSString *localName;

- (NSString *)getBluetoothName;

@end


//CBPeripheral *peripheral,NSDictionary *advertisementData,NSNumber *rssi