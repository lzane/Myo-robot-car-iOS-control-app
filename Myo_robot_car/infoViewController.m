//
//  infoViewController.m
//  Myo_robot_car
//
//  Created by zane on 11/13/15.
//  Copyright © 2015 zane. All rights reserved.
//

#import "infoViewController.h"

@interface infoViewController ()

@end

@implementation infoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
- (IBAction)backBtnDidClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}



/**
 *  force landscape in order to display lauchimage
 *  since apple don't provide 4-inch landscape launchscreen  :( bad guy
 *
 */
-(void)viewDidAppear:(BOOL)animated{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    
}

- (BOOL) shouldAutorotate
{
    // this lines permit rotate if viewController is not portrait
    UIInterfaceOrientation orientationStatusBar =[[UIApplication sharedApplication] statusBarOrientation];
    if (orientationStatusBar != UIInterfaceOrientationPortrait) {
        return NO;
    }
    //this line not permit rotate is the viewController is portrait
    return YES;
}


@end
