//
//  ViewController.m
//  FancyTabBar
//
//  Created by Jonathan on 03/09/2014.
//
//

#import "ViewController.h"



#import <MyoKit/MyoKit.h>
#import "MBProgressHUD+CZ.h"
#import "ZNCemeraView.h"
#import "BabyBluetooth.h"
#import "ZNBlueToothController.h"
#import "ZNSetingViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "armControlViewController.h"



@interface ViewController ()<UIWebViewDelegate,ZNBlueToothDelegate>


@property (nonatomic,strong) UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *blueToothLabel;
@property (weak, nonatomic) IBOutlet UILabel *myoLabel;


@property(nonatomic,strong)CMMotionManager *mgr;

@property (nonatomic,assign)BOOL isBack;
@property (nonatomic,assign)BOOL isLight;



@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    /**
     *  initialize
     */
    self.armMove = 0 ;
    self.bandMode = 0 ;
    self.armOrder1 = 1<<7 ;
    self.armOrder2 = 1<<6 ;
    
    
    /**
     * cemeraView
     */
    [self addCemera];
    
    if (!self.mgr.isAccelerometerAvailable) return;
    
    self.mgr.accelerometerUpdateInterval = 1/10.0;
    
    
    /**
     *  setHolderOrder
     *
     */
    [self.mgr startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
        if (error) return ;
        
        
        CMAcceleration acceleration = accelerometerData.acceleration;
        //        NSLog(@"x:%f y:%f z:%f", acceleration.x, acceleration.y, acceleration.z);
        
        int midOrder = 0 ;
        
        
        if (self.isLight == YES) {
            midOrder = midOrder | (1<<4) ;
        }
        
        
        
        if (acceleration.x > 0) {  // up
            midOrder = (1<<1) ;
        }else if(acceleration.z > 0.1){ // down
            midOrder = (1<<1)|1 ;
        }
        
        if (acceleration.y < -0.5) { // right
            midOrder = midOrder | (1<<3);
        }else if (acceleration.y > 0.5){ //left
            midOrder = midOrder | (1<<3) | (1<<2) ;
        }
        
        midOrder = midOrder | (1<<6) | (1<<7) ;
        
        self.holderOrder = midOrder ;
        //        NSLog(@"%d",self.holderOrder);
        
    }];
    
    
    
//    
//    /**
//     *  testSendingData without connecting the bluetooth chip using phone
//     */
//    
//        NSTimer *timer = [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(printtest) userInfo:nil repeats:YES];
//        NSRunLoop *runloop = [NSRunLoop mainRunLoop];
//        [runloop addTimer:timer forMode:NSDefaultRunLoopMode];
    
}
//
//-(void)printtest{
//    NSLog(@"moveOrder = %d", self.moveOrder);
////    NSLog(@"isLight = %d  holderOrder = %d",self.isLight , self.holderOrder );
////    NSLog(@"armOrder1 = %d     armOrder2 = %d ",self.armOrder1,self.armOrder2);
//}
//

-(void)addCemera{
    
    ZNCemeraView *cemeraView = [[ZNCemeraView alloc]initViewWithFrame:CGRectMake(0, 0, 568, 320)];
    [self.view addSubview:cemeraView];
    self.cemeraView = cemeraView ;
    [self.view sendSubviewToBack:cemeraView];
    [self.view setBackgroundColor:[UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1.0]];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"bluetoothView"]) {
        ZNBlueToothController *blue = segue.destinationViewController ;
        blue.delegate = self ;
        blue.mainVC = self ;
        self.bluetoothController = blue ;
        
        
    }
}

#pragma mark - Myo

- (void)modalPresentMyoSettings {
    UINavigationController *settings = [TLMSettingsViewController settingsInNavigationController];
    
    [self presentViewController:settings animated:YES completion:nil];
}




-(void)initMyoNotification{
    // Data notifications are received through NSNotificationCenter.
    // Posted whenever a TLMMyo connects
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectDevice:)
                                                 name:TLMHubDidConnectDeviceNotification
                                               object:nil];
    // Posted whenever a TLMMyo disconnects.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnectDevice:)
                                                 name:TLMHubDidDisconnectDeviceNotification
                                               object:nil];
    // Posted whenever the user does a successful Sync Gesture.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSyncArm:)
                                                 name:TLMMyoDidReceiveArmSyncEventNotification
                                               object:nil];
    // Posted whenever Myo loses sync with an arm (when Myo is taken off, or moved enough on the user's arm).
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUnsyncArm:)
                                                 name:TLMMyoDidReceiveArmUnsyncEventNotification
                                               object:nil];
    // Posted whenever Myo is unlocked and the application uses TLMLockingPolicyStandard.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUnlockDevice:)
                                                 name:TLMMyoDidReceiveUnlockEventNotification
                                               object:nil];
    // Posted whenever Myo is locked and the application uses TLMLockingPolicyStandard.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didLockDevice:)
                                                 name:TLMMyoDidReceiveLockEventNotification
                                               object:nil];
    // Posted when a new orientation event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveOrientationEvent:)
                                                 name:TLMMyoDidReceiveOrientationEventNotification
                                               object:nil];
    // Posted when a new accelerometer event is available from a TLMMyo. Notifications are posted at a rate of 50 Hz.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveAccelerometerEvent:)
                                                 name:TLMMyoDidReceiveAccelerometerEventNotification
                                               object:nil];
    // Posted when a new pose is available from a TLMMyo.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceivePoseChange:)
                                                 name:TLMMyoDidReceivePoseChangedNotification
                                               object:nil];
}


//hold unlock
- (void)holdUnlockForMyo:(TLMMyo *)myo {
    
    [myo unlockWithType:TLMUnlockTypeHold];
}

- (void)endHoldUnlockForMyo:(TLMMyo *)myo immediately:(BOOL)immediately {
    if (immediately) {
        [myo lock];
    } else {
        [myo unlockWithType:TLMUnlockTypeTimed];
    }
}


- (void)didConnectDevice:(NSNotification *)notification {
    
    //    TLMMyo *myo = notification.userInfo[kTLMKeyMyo];
    [self.myoLabel setText:@"CONNECTED" ];
    [self.myoLabel setFont:[UIFont boldSystemFontOfSize:14]];
    [MBProgressHUD showMessage:@"Perform the Sync Gesture" toView:self.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
    
}

- (void)didDisconnectDevice:(NSNotification *)notification {
    
    //    TLMMyo *myo = notification.userInfo[kTLMKeyMyo];
    [self.myoLabel setText:@"DISCONNECTED" ];
    [self.myoLabel setFont:[UIFont systemFontOfSize:14]];
    
}

- (void)didUnlockDevice:(NSNotification *)notification {
    // Update the label to reflect Myo's lock state.
    TLMMyo *myo = notification.userInfo[kTLMKeyMyo];
    
    [myo unlockWithType:TLMUnlockTypeHold];
    
    self.armOrder1 = 1<<7 ;
    self.armOrder2 = 1<<6 ;
    
    
}

- (void)didLockDevice:(NSNotification *)notification {
    // Update the label to reflect Myo's lock state.
    
}

- (void)didSyncArm:(NSNotification *)notification {
    // Retrieve the arm event from the notification's userInfo with the kTLMKeyArmSyncEvent key.
    //    TLMArmSyncEvent *armEvent = notification.userInfo[kTLMKeyArmSyncEvent];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Update the armLabel with arm information.
    
    //    NSString *armString = armEvent.arm == TLMArmRight ? @"Right" : @"Left";
    //    NSString *directionString = armEvent.xDirection == TLMArmXDirectionTowardWrist ? @"Toward Wrist" : @"Toward Elbow";
    
    
    
    
}

- (void)didUnsyncArm:(NSNotification *)notification {
    // Reset the labels.
    if([self.myoLabel.text isEqualToString:@"CONNECTED"]){
        [MBProgressHUD showMessage:@"Perform the Sync Gesture" toView:self.view];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    }
}

- (void)didReceiveOrientationEvent:(NSNotification *)notification {
    // Retrieve the orientation from the NSNotification's userInfo with the kTLMKeyOrientationEvent key.
    TLMOrientationEvent *orientationEvent = notification.userInfo[kTLMKeyOrientationEvent];
    
    if (orientationEvent.myo.isLocked == YES) {
        return ;
    }
    
    // Create Euler angles from the quaternion of the orientation.
    TLMEulerAngles *angles = [TLMEulerAngles anglesWithQuaternion:orientationEvent.quaternion];
    
    /**
     *  if put hand down , lock the Myo
     */
    if (angles.pitch.radians < -1.2 && orientationEvent.myo.isLocked == NO ) {
        
        [orientationEvent.myo lock];
        self.armMove = 0 ;
        self.moveOrder = 0x00 ;
    }
    
    /**
     * bandMode to control arm
     */
    if (self.bandMode == 0) {
        
        self.armOrder1 = self.armOrder1 & 204 ;
        
        
        
        //    NSLog(@"roll:%lf   pitch:%lf     yaw:%lf   ",angles.roll.radians,angles.pitch.radians,angles.yaw.radians);
        
        
        if (angles.roll.radians < -0.6 ) { //right
            self.armOrder1 = self.armOrder1 | (1<<1) ;
        }else if(angles.roll.radians >0.6 ){ //left
            self.armOrder1 = self.armOrder1 | (1<<1) | (1<<0) ;
        }
        
        
        if (angles.pitch.radians < -0.6 ) { //down
            self.armOrder1 = self.armOrder1 | (1<<5) | (1<<4) ;
        }else if(angles.pitch.radians >0.6 ){ //up
            self.armOrder1 = self.armOrder1 | (1<<5) ;
        }
        
    }
    /**
     *  bandMode to control direction
     *
     */
    else if(self.bandMode == 1){
        if (self.armMove == 0) return ;
        
        if (angles.roll.radians < -0.6 ) { //right
            self.moveOrder = 0xB ; // 0000 1011
        }else if(angles.roll.radians >0.6 ){ //left
            self.moveOrder = 0xC ; // 0000 1100
        }else{
            self.moveOrder = 0x9 ; // 0000 1001
        }
        
    }
    
    
    
    
    
}

- (void)didReceiveAccelerometerEvent:(NSNotification *)notification {
    // Retrieve the accelerometer event from the NSNotification's userInfo with the kTLMKeyAccelerometerEvent.
    //    TLMAccelerometerEvent *accelerometerEvent = notification.userInfo[kTLMKeyAccelerometerEvent];
    
    // Get the acceleration vector from the accelerometer event.
    //    TLMVector3 accelerationVector = accelerometerEvent.vector;
    
    // Calculate the magnitude of the acceleration vector.
    //    float magnitude = TLMVector3Length(accelerationVector);
    
    // Update the progress bar based on the magnitude of the acceleration vector.
    //    self.accelerationProgressBar.progress = magnitude / 8;
    
    /* Note you can also access the x, y, z values of the acceleration (in G's) like below
     float x = accelerationVector.x;
     float y = accelerationVector.y;
     float z = accelerationVector.z;
     */
    
}

- (void)didReceivePoseChange:(NSNotification *)notification {
    // Retrieve the pose from the NSNotification's userInfo with the kTLMKeyPose key.
    TLMPose *pose = notification.userInfo[kTLMKeyPose];
    NSLog(@"%s   + %ld", __func__,(long)pose.type);
    
    //    // Handle the cases of the TLMPoseType enumeration, and change the color of helloLabel based on the pose we receive.
    if(self.bandMode == 0 ){
        switch (pose.type) {
                //        case TLMPoseTypeUnknown:
                //            break;
            case TLMPoseTypeRest:
                self.armOrder2 = 1<<6 ;
                self.armOrder1 = self.armOrder1 & 243 ;
                break;
                //        case TLMPoseTypeDoubleTap:
                //            // Changes helloLabel's font to Helvetica Neue when the user is in a rest or unknown pose.
                break;
            case TLMPoseTypeFist:
                // Changes helloLabel's font to Noteworthy when the user is in a fist pose.
                self.armOrder2 = self.armOrder2 | 32 ;
                break;
                
            case TLMPoseTypeFingersSpread:
                // Changes helloLabel's font to Chalkduster when the user is in a fingers spread pose.
                self.armOrder2 = self.armOrder2 | 48 ;
                break;
                
            case TLMPoseTypeWaveIn:
                // Changes helloLabel's font to Courier New when the user is in a wave in pose.
                self.armOrder1 = self.armOrder1 | 8 ;
                break;
            case TLMPoseTypeWaveOut:
                self.armOrder1 = self.armOrder1 | 12 ;
                break;
                
            default:
                break;
        }
    }else if(self.bandMode == 1){
        switch (pose.type) {
                //        case TLMPoseTypeUnknown:
                //            break;
//            case TLMPoseTypeRest:
//                self.armMove = 0 ;
//                self.moveOrder = 0x00 ;
//                break;
//                //        case TLMPoseTypeDoubleTap:
//                //            // Changes helloLabel's font to Helvetica Neue when the user is in a rest or unknown pose.
//                break;
//            case TLMPoseTypeFist:
//                // Changes helloLabel's font to Noteworthy when the user is in a fist pose.
//                self.armMove = 0 ;
//                self.moveOrder = 0x00 ;
//                break;
//                
            case TLMPoseTypeFingersSpread:
                // Changes helloLabel's font to Chalkduster when the user is in a fingers spread pose.
                self.armMove = 1;
                self.moveOrder = 0x9 ; // 0000 1001
                break;
                
            case TLMPoseTypeWaveIn:
                // Changes helloLabel's font to Courier New when the user is in a wave in pose.
                self.moveOrder = 0xA ; // 0000 1010;
                self.armMove = 0 ;
                break;
                
            case TLMPoseTypeWaveOut:
                self.armMove = 1;
                self.moveOrder = 0x9 ; // 0000 1001
                break;

            default:
                self.armMove = 0 ;
                self.moveOrder = 0x00 ;
                break;
                
        }
    }
    
    // Unlock the Myo whenever we receive a pose
    if (pose.type == TLMPoseTypeUnknown || pose.type == TLMPoseTypeRest) {
        // Causes the Myo to lock after a short period.
        //        [pose.myo unlockWithType:TLMUnlockTypeTimed];
        
        
    } else {
        
        [self holdUnlockForMyo:pose.myo];
        
        // Indicates that a user action has been performed.
        [pose.myo indicateUserAction];
    }
}



#pragma mark -ZNBluetooth

-(void)changeBlueToothConnectTo:(BOOL)connectivity{
    if (connectivity) {
        [self.blueToothLabel setText:@"CONNECTED" ];
        [self.blueToothLabel setFont:[UIFont boldSystemFontOfSize:14]];
        
        
    }else{
        [self.blueToothLabel setText:@"DISCONNECTED" ];
        [self.blueToothLabel setFont:[UIFont systemFontOfSize:14]];
        
    }
}


#pragma mark -- mermory issue
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.cemeraView removeFromSuperview];
    self.cemeraView = nil;
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [self addCemera];
}

#pragma mark -- 懒加载

-(ZNSetingViewController *)settingVC{
    if (!_settingVC) {
        _settingVC = [[ZNSetingViewController alloc]init];
        self.settingVC.view.frame = CGRectMake(0, 0, 305, 75);
        self.settingVC.view.center = CGPointMake(self.view.center.x, -80 );
        _settingVC.mainVC = self ;
        [self.view addSubview:self.settingVC.view];
    }
    return _settingVC ;
}

- (CMMotionManager *)mgr
{
    if (_mgr == nil) {
        _mgr = [[CMMotionManager alloc] init];
    }
    return _mgr;
}


-(armControlViewController *)armControlVC{
    if (_armControlVC == nil) {
        _armControlVC = [[armControlViewController alloc]init];
        _armControlVC.view.frame = CGRectMake(0, 0, 145, 246);
        _armControlVC.view.center = self.view.center ;
        [_armControlVC.view  setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
        _armControlVC.isDisplay = NO ;
        _armControlVC.mainVC = self ;
    }
    return _armControlVC ;
}

#pragma mark -- Button method

- (IBAction)settingBtnDidClick:(id)sender {
    UIButton *btn = sender ;
    [btn setSelected:YES ] ;
    [self.view bringSubviewToFront:self.settingVC.view];
    
    if (self.settingVC.view.center.y == -80 ) {
        [UIView animateWithDuration:0.5 animations:^{
            self.settingVC.view.center = CGPointMake(self.view.center.x, self.view.center.y - 30);
        }];
    }else{
        [self.settingVC hideSettingView];
    }
    
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.settingVC) {
        [self.settingVC hideSettingView];
    }
}
- (IBAction)lightBtnDidClick:(id)sender {
    
    
    UIButton *senderBtn = sender ;
    [senderBtn setSelected:!senderBtn.isSelected];
    self.isLight = !self.isLight ;
    
}

- (IBAction)changeBandModeBtnDidClick:(id)sender {
    UIButton *senderBtn = sender ;
    if (self.bandMode == 0) {
        self.bandMode = 1 ;
        senderBtn.selected = YES ;
    }else if(self.bandMode == 1){
        self.bandMode = 0 ;
        senderBtn.selected = NO ;
    }
}

#pragma mark -- force orientation
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
