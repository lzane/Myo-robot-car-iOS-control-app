//
//  ZNSetingViewController.m
//  Myo_robot_car
//
//  Created by zane on 10/31/15.
//  Copyright © 2015 zane. All rights reserved.
//

#import "ZNSetingViewController.h"
#import "ViewController.h"
#import "armControlViewController.h"

@interface ZNSetingViewController ()

@end

@implementation ZNSetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)hideSettingView{
    [UIView animateWithDuration:0.3 animations:^{
    self.view.center = CGPointMake(self.view.center.x, -80);
    [self.mainVC.settingBtn setSelected:NO];
    }];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)MyoBtnDidClick:(id)sender {
    [self.mainVC initMyoNotification];
    [self.mainVC modalPresentMyoSettings];
    [self hideSettingView];
}

- (IBAction)bluetoothBtnDidClick:(id)sender {
    
    if (!self.mainVC.bluetoothController) {
        [self.mainVC performSegueWithIdentifier:@"bluetoothView" sender:nil];
    }else{
        [self.mainVC presentViewController:(UIViewController*)self.mainVC.bluetoothController animated:YES completion:^{
        }];
    }
    
    [self hideSettingView];
}

- (IBAction)armControlBtnDidClick:(id)sender {
    
    if (self.mainVC.armControlVC.isDisplay == YES) {
        [self.mainVC.armControlVC.view removeFromSuperview];
        self.mainVC.armControlVC.isDisplay = NO ;
    }else{
        [self.mainVC.view addSubview:self.mainVC.armControlVC.view];
        [self.mainVC.view bringSubviewToFront:self.mainVC.settingVC.view];
        self.mainVC.armControlVC.isDisplay = YES ;
    }
    
       [self hideSettingView];
    
    
}
- (IBAction)infoBtnDidClick:(id)sender {
    [self.mainVC performSegueWithIdentifier:@"toInfo" sender:sender];
    [self hideSettingView];
}

@end
