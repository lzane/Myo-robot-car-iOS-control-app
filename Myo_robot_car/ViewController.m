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


@interface ViewController ()<ZNBlueToothDelegate>


@property (nonatomic,strong) UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UILabel *blueToothLabel;
@property (weak, nonatomic) IBOutlet UILabel *myoLabel;
@property (strong,nonatomic) ZNCemeraView *cemeraView;

@property (strong, nonatomic) ZNBlueToothController* bluetoothController ;




@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    /**
     * cemeraView
     */
    [self addCemera];
    
}

-(void)addCemera{
    ZNCemeraView *cemeraView = [[ZNCemeraView alloc]initViewWithFrame:CGRectMake(0, 0, 950, 320)];
    cemeraView.scalesPageToFit = YES ;
    [self.view addSubview:cemeraView];
    self.cemeraView = cemeraView ;
}


#pragma mark - FancyTabBarDelegate
- (void) didCollapse{
    [UIView animateWithDuration:0.3 animations:^{
        _backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        if(finished) {
            [_backgroundView removeFromSuperview];
            _backgroundView = nil;
        }
    }];
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
    NSLog(@"%s",__func__);
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
    [MBProgressHUD showMessage:@"Perform the Sync Gesture" toView:self.view];
    
}

- (void)didDisconnectDevice:(NSNotification *)notification {
    
//    TLMMyo *myo = notification.userInfo[kTLMKeyMyo];
    [self.myoLabel setText:@"DISCONNECTED" ];
    
}

- (void)didUnlockDevice:(NSNotification *)notification {
    // Update the label to reflect Myo's lock state.
    TLMMyo *myo = notification.userInfo[kTLMKeyMyo];
    
    [myo unlockWithType:TLMUnlockTypeHold];

    
}

- (void)didLockDevice:(NSNotification *)notification {
    // Update the label to reflect Myo's lock state.

}

- (void)didSyncArm:(NSNotification *)notification {
    // Retrieve the arm event from the notification's userInfo with the kTLMKeyArmSyncEvent key.
    TLMArmSyncEvent *armEvent = notification.userInfo[kTLMKeyArmSyncEvent];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    // Update the armLabel with arm information.
    
//    NSString *armString = armEvent.arm == TLMArmRight ? @"Right" : @"Left";
//    NSString *directionString = armEvent.xDirection == TLMArmXDirectionTowardWrist ? @"Toward Wrist" : @"Toward Elbow";
    

}

- (void)didUnsyncArm:(NSNotification *)notification {
    // Reset the labels.
    if([self.myoLabel.text isEqualToString:@"CONNECTED"]){
    [MBProgressHUD showMessage:@"Perform the Sync Gesture" toView:self.view];
    }
}

- (void)didReceiveOrientationEvent:(NSNotification *)notification {
    // Retrieve the orientation from the NSNotification's userInfo with the kTLMKeyOrientationEvent key.
    TLMOrientationEvent *orientationEvent = notification.userInfo[kTLMKeyOrientationEvent];
    
    // Create Euler angles from the quaternion of the orientation.
    TLMEulerAngles *angles = [TLMEulerAngles anglesWithQuaternion:orientationEvent.quaternion];
    
    
//    NSLog(@"pitch : %lf  yaw : %lf    roll :  %lf   ",angles.pitch.radians,angles.yaw.radians,angles.roll.radians);
    
    // Next, we want to apply a rotation and perspective transformation based on the pitch, yaw, and roll.
    CATransform3D rotationAndPerspectiveTransform = CATransform3DConcat(CATransform3DConcat(CATransform3DRotate (CATransform3DIdentity, angles.pitch.radians, 1.0, 0.0, 0.0), CATransform3DRotate(CATransform3DIdentity, angles.yaw.radians, 0.0, 0.0, 1.0)), CATransform3DRotate(CATransform3DIdentity, angles.roll.radians, 0.0, 1.0, 0.0 ));

    
    
    
    if (angles.pitch.radians < -1.0 && orientationEvent.myo.isLocked == NO ) {
        [orientationEvent.myo lock];
    }
    
    
}

- (void)didReceiveAccelerometerEvent:(NSNotification *)notification {
    // Retrieve the accelerometer event from the NSNotification's userInfo with the kTLMKeyAccelerometerEvent.
    TLMAccelerometerEvent *accelerometerEvent = notification.userInfo[kTLMKeyAccelerometerEvent];
    
    // Get the acceleration vector from the accelerometer event.
    TLMVector3 accelerationVector = accelerometerEvent.vector;
    
    // Calculate the magnitude of the acceleration vector.
    float magnitude = TLMVector3Length(accelerationVector);
    
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
    NSLog(@"%s   + %ld",__func__,(long)pose.type);
    
    self.moveOrder = pose.type ;
    
    
//    // Handle the cases of the TLMPoseType enumeration, and change the color of helloLabel based on the pose we receive.
//    switch (pose.type) {
//        case TLMPoseTypeUnknown:
//        case TLMPoseTypeRest:
//        case TLMPoseTypeDoubleTap:
//            // Changes helloLabel's font to Helvetica Neue when the user is in a rest or unknown pose.
//            self.helloLabel.text = @"Hello Myo";
//            self.helloLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:50];
//            self.helloLabel.textColor = [UIColor blackColor];
//            break;
//        case TLMPoseTypeFist:
//            // Changes helloLabel's font to Noteworthy when the user is in a fist pose.
//            self.helloLabel.text = @"Fist";
//            self.helloLabel.font = [UIFont fontWithName:@"Noteworthy" size:50];
//            self.helloLabel.textColor = [UIColor greenColor];
//            break;
//        case TLMPoseTypeWaveIn:
//            // Changes helloLabel's font to Courier New when the user is in a wave in pose.
//            self.helloLabel.text = @"Wave In";
//            self.helloLabel.font = [UIFont fontWithName:@"Courier New" size:50];
//            self.helloLabel.textColor = [UIColor greenColor];
//            break;
//        case TLMPoseTypeWaveOut:
//            // Changes helloLabel's font to Snell Roundhand when the user is in a wave out pose.
//            self.helloLabel.text = @"Wave Out";
//            self.helloLabel.font = [UIFont fontWithName:@"Snell Roundhand" size:50];
//            self.helloLabel.textColor = [UIColor greenColor];
//            break;
//        case TLMPoseTypeFingersSpread:
//            // Changes helloLabel's font to Chalkduster when the user is in a fingers spread pose.
//            self.helloLabel.text = @"Fingers Spread";
//            self.helloLabel.font = [UIFont fontWithName:@"Chalkduster" size:50];
//            self.helloLabel.textColor = [UIColor greenColor];
//            break;
//    }
    
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
        [self.blueToothLabel setTextColor:[UIColor blackColor]];

    }else{
        [self.blueToothLabel setText:@"DISCONNECTED" ];
        [self.blueToothLabel setTextColor:[UIColor lightGrayColor]];
        [self.blueToothLabel setFont:[UIFont systemFontOfSize:14]];

    }
}


#pragma mark -- mermory issue
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.cemeraView removeFromSuperview ];
    self.cemeraView = nil ;
    
    [self addCemera];
}


@end
