//
//  ZNBlueToothController.m
//  Myo_robot_car
//
//  Created by zane on 10/28/15.
//  Copyright © 2015 zane. All rights reserved.
//

#import "ZNBlueToothController.h"
#import "BabyBluetooth.h"
#import "ViewController.h"
#import "MBProgressHUD+CZ.h"

#define channelOnPeropheralView @"peripheralView"


@interface ZNBlueToothController (){
    
    __block BabyBluetooth *baby;

}

@property (weak, nonatomic) IBOutlet UILabel *currentOrderLabel;

@property(nonatomic,strong) CBPeripheral *peripheral ;
@property (nonatomic,strong) NSMutableArray *serviceArr ;
@property (nonatomic,strong) CBCharacteristic* charac ;
@property (weak, nonatomic) IBOutlet UITextField *orderTextField;




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
    
    [MBProgressHUD showMessage:@"Connecting..."];
    
    [baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        //设置连接成功的block
        NSLog(@"设备：%@--连接成功",peripheral.name);
        
    }];
    
     __block ZNBlueToothController* btc = self;
    //设置发现设备的Services的委托
    [baby setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        for (CBService *s in peripheral.services) {
            //每个service
            [btc.serviceArr addObject:s];
        }
    }];
    
    [baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"===service name:%@",service.UUID);
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"charateristic name is :%@",c.UUID);
            if ([c.UUID.UUIDString isEqualToString:@"FFE1"]) {
                btc.charac = c ;
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
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.3 target:self selector:@selector(sendData) userInfo:nil repeats:YES];
    NSRunLoop *runloop = [NSRunLoop mainRunLoop];
    [runloop addTimer:timer forMode:NSRunLoopCommonModes];
    
    [MBProgressHUD showSuccess:@"Timer start"];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUD];
    });

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
    self.mainVC.moveOrder = [tf.text intValue];
}


#pragma mark - <Bluetooth Delegate>
-(void)babyDelegate{
    
    __block BabyBluetooth* bab = baby ;
    __block ZNBlueToothController *btc = self;
    //设置扫描到设备的委托
    [baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        NSLog(@"搜索到了设备:%@",peripheral.name);
        if([peripheral.name hasPrefix:@"<6666"]||[peripheral.name hasPrefix:@"6666"]){
            bab.scanForPeripherals().connectToPeripherals().begin();
            
            btc.peripheral = peripheral;
            
            if([btc.delegate respondsToSelector:@selector(changeBlueToothConnectTo:)]){
                [btc.delegate changeBlueToothConnectTo:YES];
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
    if (self.peripheral) {
        baby.having(self.peripheral).connectToPeripherals().discoverServices().discoverCharacteristics()
        .readValueForCharacteristic().discoverDescriptorsForCharacteristic().readValueForDescriptors().begin();
        
         [MBProgressHUD hideHUD];
        [MBProgressHUD showSuccess:@"Connect success"];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });

        
    }else{
        [MBProgressHUD showError:@"Cannot connect to Bluetooth"];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUD];
        });
    }
   
}


- (IBAction)backBtnClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(void)sendData{
    
    [self.currentOrderLabel setText:[NSString stringWithFormat:@"%d",self.mainVC.moveOrder]] ;
//    NSLog(@"%d",self.mainVC.moveOrder);
    
    /**
     *  send moveOrder
     */
    Byte moveb = self.mainVC.moveOrder;
    NSData *moveData = [NSData dataWithBytes:&moveb length:sizeof(moveb)];
    [self.peripheral writeValue:moveData forCharacteristic:self.charac type:CBCharacteristicWriteWithResponse];
    
    /**
     *  send holderOrder
     */
    Byte holderb = self.mainVC.holderOrder ;
    NSData *holderData = [NSData dataWithBytes:&holderb length:sizeof(holderb)];
    [self.peripheral writeValue:holderData forCharacteristic:self.charac type:CBCharacteristicWriteWithResponse];
    
    /**
     *  send armOrder1
     */
    Byte arm1b = self.mainVC.armOrder1 ;
    NSData *arm1Data = [NSData dataWithBytes:&arm1b length:sizeof(arm1b)];
    [self.peripheral writeValue:arm1Data forCharacteristic:self.charac type:CBCharacteristicWriteWithResponse];

    
    /**
     *  send armOrder2
     */
    Byte arm2b = self.mainVC.armOrder2 ;
    NSData *arm2Data = [NSData dataWithBytes:&arm2b length:sizeof(arm2b)];
    [self.peripheral writeValue:arm2Data forCharacteristic:self.charac type:CBCharacteristicWriteWithResponse];
    
//    NSLog(@"moveOrder:%d     holderOreder:%d       armOrder1:%d     armOder2:%d       ",self.mainVC.moveOrder,self.mainVC.holderOrder,self.mainVC.armOrder1,self.mainVC.armOrder2);
    
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
