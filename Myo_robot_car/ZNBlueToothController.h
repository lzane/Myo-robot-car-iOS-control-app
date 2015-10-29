//
//  ZNBlueToothController.h
//  Myo_robot_car
//
//  Created by zane on 10/28/15.
//  Copyright © 2015 zane. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol ZNBlueToothDelegate <NSObject>

-(void)changeBlueToothConnectTo:(BOOL)connectivity;



@end

@interface ZNBlueToothController : UIViewController


@property (nonatomic,weak) id<ZNBlueToothDelegate> delegate;
@end

