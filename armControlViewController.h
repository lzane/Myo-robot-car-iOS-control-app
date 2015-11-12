//
//  armControlViewController.h
//  Myo_robot_car
//
//  Created by zane on 11/12/15.
//  Copyright © 2015 zane. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ViewController;

@interface armControlViewController : UIViewController
@property (nonatomic,assign) BOOL isDisplay ;
@property (nonatomic,weak) ViewController* mainVC ;

@end
