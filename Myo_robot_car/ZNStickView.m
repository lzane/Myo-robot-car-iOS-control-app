//
//  ZNStickView.m
//  Myo_robot_car
//
//  Created by zane on 10/30/15.
//  Copyright © 2015 zane. All rights reserved.
//

#import "ZNStickView.h"
#include "ViewController.h"


@interface ZNStickView ()

@property (nonatomic,weak) IBOutlet ViewController *mainVC ;
@property (nonatomic,strong) IBOutlet UIImageView* stickImageView ;
@property (nonatomic,strong) IBOutlet UIImageView* backgroundImageView ;
@property (nonatomic,strong) UIImage *stickHoldOnImage ;
@property (nonatomic,strong) UIImage *stickReleaseImage ;

@property (nonatomic,strong) NSDictionary *stickPosition ;

@end



@implementation ZNStickView


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    self.stickImageView.image = self.stickHoldOnImage;
    
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self];
    CGPoint centerPoint = self.backgroundImageView.center ;
    double angle = atan( ( centerPoint.y - currentPoint.y  )/(currentPoint.x - centerPoint.x));
    
//    NSLog(@"%@",NSStringFromCGPoint(currentPoint));
//    NSLog(@"%@",NSStringFromCGPoint(centerPoint));
//    NSLog(@"%lf",angle);
    
    NSValue *value;
    
        if (angle > M_PI / 6 && angle < M_PI /3) {
            
            if (currentPoint.y < centerPoint.y) {
                //top_right
                value = self.stickPosition[@"top_right"] ;
                self.mainVC.moveOrder = 0x8 ; // 0000 1000
            }else{
                //back_left
                value = self.stickPosition[@"back_left"] ;
                self.mainVC.moveOrder = 0xE ; // 0000 1001
            }
            
        }else if((angle >M_PI / 3 && angle < M_PI /2)||(angle < - M_PI /3  && angle > - M_PI /2)){
            
            if (currentPoint.y < centerPoint.y) {
                //top
                value = self.stickPosition[@"top"] ;
                self.mainVC.moveOrder = 0x9 ; // 0000 1001
            }else{
                //back
                value = self.stickPosition[@"back"] ;
                self.mainVC.moveOrder = 0xA ; // 0000 1010
            }
         
        }else if(angle < -M_PI  /6 && angle > - M_PI /3 ){
            
            if (currentPoint.y < centerPoint.y) {
                //top_left
                value = self.stickPosition[@"top_left"] ;
                self.mainVC.moveOrder = 0xD ; // 0000 1101
            }else{
                //back_right
                value = self.stickPosition[@"back_right"] ;
                self.mainVC.moveOrder = 0xF ; // 0000 1111
            }
            
        }else{
            
            if (currentPoint.x < centerPoint.x) {
                //left
                value = self.stickPosition[@"left"] ;
                self.mainVC.moveOrder = 0xC ; // 0000 1100
            }else{
                //right
                value = self.stickPosition[@"right"] ;
                self.mainVC.moveOrder = 0xB ; // 0000 1011
            }
            
        }
    
    self.stickImageView.center = [value CGPointValue];
    
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    self.stickImageView.image = self.stickReleaseImage;
    self.stickImageView.center = self.backgroundImageView.center ;
    
    self.mainVC.moveOrder = 0x00 ;
    
}


#pragma mark -- 懒加载代码

-(UIImage *)stickHoldOnImage{
    if (!_stickHoldOnImage) {
        _stickHoldOnImage = [UIImage imageNamed:@"top(Click_on)"];
    }
    return _stickHoldOnImage;
    
}

-(UIImage *)stickReleaseImage{
    if (!_stickReleaseImage) {
        _stickReleaseImage = [UIImage imageNamed:@"top(release)"];
    }
    return _stickReleaseImage ;
}

-(NSDictionary *)stickPosition{
    if (!_stickPosition) {
        
        
        CGPoint point1 = CGPointMake(64, 31) ;// top
        CGPoint point2 = CGPointMake(41, 42) ;// top_left
        CGPoint point3 = CGPointMake(87, 42) ;// top_right
        CGPoint point4 = CGPointMake(32, 64) ;// left
        CGPoint point5 = CGPointMake(96, 64) ;// right
        CGPoint point6 = CGPointMake(41, 88) ;// back_left
        CGPoint point7 = CGPointMake(87, 88) ;// back_right
        CGPoint point8 = CGPointMake(64, 97) ;// back

        
        NSValue *value1 = [NSValue valueWithCGPoint:point1];
        NSValue *value2 = [NSValue valueWithCGPoint:point2];
        NSValue *value3 = [NSValue valueWithCGPoint:point3];
        NSValue *value4 = [NSValue valueWithCGPoint:point4];
        NSValue *value5 = [NSValue valueWithCGPoint:point5];
        NSValue *value6 = [NSValue valueWithCGPoint:point6];
        NSValue *value7 = [NSValue valueWithCGPoint:point7];
        NSValue *value8 = [NSValue valueWithCGPoint:point8];
        
        _stickPosition = [[NSDictionary alloc]initWithObjectsAndKeys:value1,@"top",value2,@"top_left",value3,@"top_right",value4,@"left",value5,@"right",value6,@"back_left",value7,@"back_right",value8,@"back", nil ];
        
    }

    return _stickPosition ;
}






@end
