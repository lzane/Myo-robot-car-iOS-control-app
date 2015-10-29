//
//  ZNBlueToothController.m
//  Myo_robot_car
//
//  Created by zane on 10/28/15.
//  Copyright © 2015 zane. All rights reserved.
//

#import "ZNBlueToothController.h"
#import "BabyBluetooth.h"

#define channelOnPeropheralView @"peripheralView"


@interface ZNBlueToothController (){
    
    BabyBluetooth *baby;

}


@property(nonatomic,strong) CBPeripheral *peripheral ;
@property (nonatomic,strong) NSMutableArray *serviceArr ;
@property (nonatomic,strong) CBCharacteristic* charac ;
@property (weak, nonatomic) IBOutlet UITextField *orderTextField;
@property (assign,nonatomic) int order ;


@end

@implementation ZNBlueToothController


-(NSMutableArray *)serviceArr{
    if (!_serviceArr) {
        _serviceArr = [NSMutableArray array];
    }
    return _serviceArr;
}

- (IBAction)connectBtnDidClick:(id)sender {
    /**
     *  Bluetooth
     */
    //初始化BabyBluetooth 蓝牙库
    baby = [BabyBluetooth shareBabyBluetooth];
    
    
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        //设置连接成功的block
        NSLog(@"设备：%@--连接成功",peripheral.name);
        
    }];
    
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *s in peripheral.services) {
            //每个service
            [self.serviceArr addObject:s];
        }
    }];
    
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"charateristic name is :%@",c.UUID);
            if ([c.UUID.UUIDString isEqualToString:@"FFE1"]) {
                self.charac = c ;
            }
        }
    }];
    //设置读取characteristics的委托
    [baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        NSLog(@"characteristic name:%@ value is:%@",characteristics.UUID,characteristics.value);
    }];
    
    //        //设置发现characteristics的descriptors的委托
    //        [baby setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
    //            NSLog(@"===characteristic name:%@",characteristic.service.UUID);
    //            for (CBDescriptor *d in characteristic.descriptors) {
    //                NSLog(@"CBDescriptor name is :%@",d.UUID);
    //            }
    //        }];
    //        //设置读取Descriptor的委托
    //        [baby setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
    //            NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    //        }];
    
    
    
    
    
    
    //设置蓝牙委托
    [self babyDelegate];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态
    baby.scanForPeripherals().begin();
    
}


- (IBAction)startTimerBtnDidClick:(id)sender {
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(sendData) userInfo:nil repeats:YES];
    NSRunLoop *runloop = [NSRunLoop mainRunLoop];
    [runloop addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)orderTextFieldEditingEnd:(id)sender {
    UITextField *tf = sender ;
    self.order = [tf.text intValue];
}


#pragma mark - <Bluetooth Delegate>
-(void)babyDelegate{
    
    
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        if([peripheral.name hasPrefix:@"<6666"]){
            baby.scanForPeripherals().connectToPeripherals().begin();
            
            self.peripheral = peripheral;
            
            if([self.delegate respondsToSelector:@selector(changeBlueToothConnectTo:)]){
                [self.delegate changeBlueToothConnectTo:YES];
            }
            
        }
    }];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getinfo];
    });

    
}


-(void)getinfo{
    //设置peripheral 然后读取services,然后读取characteristics名称和值和属性，获取characteristics对应的description的名称和值
    //self.peripheral是一个CBPeripheral实例
    
    baby.having(self.peripheral).connectToPeripherals().discoverServices().discoverCharacteristics()
    .readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();

}


- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(void)sendData{

    Byte b = self.order;
    NSData *data = [NSData dataWithBytes:&b length:sizeof(b)];
    [self.peripheral writeValue:data forCharacteristic:self.charac type:CBCharacteristicWriteWithResponse];

}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
