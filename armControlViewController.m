//
//  armControlViewController.m
//  Myo_robot_car
//
//  Created by zane on 11/12/15.
//  Copyright © 2015 zane. All rights reserved.
//

#import "armControlViewController.h"
#include "ViewController.h"
@interface armControlViewController ()
@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;
@property (weak, nonatomic) IBOutlet UISlider *slider3;
@property (weak, nonatomic) IBOutlet UISlider *slider4;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeGesture;

@end

@implementation armControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.swipeGesture.direction = UISwipeGestureRecognizerDirectionDown ;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)touchUpInside:(id)sender {
    [self touchesEnded:nil withEvent:nil];
}

- (IBAction)touchUpOutside:(id)sender {
    [self touchesEnded:nil withEvent:nil];
}


-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self initializeValue];
}

-(void)initializeValue{
    self.slider1.value = 0.5 ;
    self.slider2.value = 0.5 ;
    self.slider3.value = 0.5 ;
    self.slider4.value = 0.5 ;
    self.mainVC.armOrder2 = 1<<6 ;
    self.mainVC .armOrder1 = 1<<7 ;
}


- (IBAction)sliderValueChanged:(id)sender {
    
    if (self.slider1.value < 0.3) {
        self.mainVC.armOrder1 = self.mainVC.armOrder1 | (1<<5) | (1<<4) ; //down
    }else if(self.slider1.value > 0.7){
        self.mainVC.armOrder1 = self.mainVC.armOrder1 | (1<<5) ; // up
    }
    
    
    if (self.slider2.value < 0.3) {
        self.mainVC.armOrder1 = self.mainVC.armOrder1 | 8 ;//down   (wave in)
    }else if(self.slider2.value > 0.7){
          self.mainVC.armOrder1 = self.mainVC.armOrder1 | 12 ;//up    (wave out)
    }
    
    
    if (self.slider3.value < 0.3) {
        self.mainVC.armOrder1 = self.mainVC.armOrder1 | (1<<1) ;//right
    }else if(self.slider3.value > 0.7){
        self.mainVC.armOrder1 = self.mainVC.armOrder1 | (1<<1) | (1<<0) ;//left    
    }
    
    if (self.slider4.value < 0.3) {
        self.mainVC.armOrder2 = self.mainVC.armOrder2| 32 ; //(fist)
    }else if(self.slider4.value > 0.7){
        self.mainVC.armOrder2 = self.mainVC.armOrder2 | 48 ;//(spread)
    }
    
    
}


- (IBAction)SwipeGuestureDidSwipre:(id)sender {
    
    

    [UIView animateWithDuration:0.3 animations:^{
        self.view.center = CGPointMake(800, self.mainVC.view.center.y);
    } completion:^(BOOL finished) {
        self.view.center = self.mainVC.view.center ;
        [self.view removeFromSuperview];
        self.isDisplay = NO ;
        [self initializeValue];
    }];
    
}



@end
