//
//  armControlViewController.m
//  Myo_robot_car
//
//  Created by zane on 11/12/15.
//  Copyright © 2015 zane. All rights reserved.
//

#import "armControlViewController.h"

@interface armControlViewController ()
@property (weak, nonatomic) IBOutlet UISlider *slider1;
@property (weak, nonatomic) IBOutlet UISlider *slider2;
@property (weak, nonatomic) IBOutlet UISlider *slider3;

@end

@implementation armControlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
    self.slider1.value = 0.5 ;
    self.slider2.value = 0.5 ;
    self.slider3.value = 0.5 ;
}





@end
