//
//  ViewController.h
//  Myo_robot_car
//
//  Created by zane on 10/20/15.
//  Copyright (c) 2015 zane. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface ViewController : UIViewController


@end

@protocol blueDataDelegate <NSObject>

-(void)blueDataDelegateSend:(Byte)byte;

@end