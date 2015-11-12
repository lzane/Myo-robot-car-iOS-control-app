//
//  ViewController.h
//  Myo_robot_car
//
//  Created by zane on 10/20/15.
//  Copyright (c) 2015 zane. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZNCemeraView,ZNBlueToothController;

@interface ViewController : UIViewController

@property (nonatomic,assign) int moveOrder ;
@property (nonatomic,assign) int holderOrder ;
@property (nonatomic,assign) int armOrder1 ;
@property (nonatomic,assign) int armOrder2 ;


@property (strong,nonatomic) ZNCemeraView *cemeraView;

@property (strong, nonatomic) ZNBlueToothController* bluetoothController ;

@property (weak, nonatomic) IBOutlet UIButton *settingBtn;


-(void)addCemera;
-(void)initMyoNotification;
- (void)modalPresentMyoSettings;


@end

@protocol blueDataDelegate <NSObject>


-(void)blueDataDelegateSend:(Byte)byte;

@end