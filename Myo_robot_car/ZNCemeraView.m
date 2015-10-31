//
//  ZNCemeraView.m
//  Myo_robot_car
//
//  Created by zane on 10/22/15.
//  Copyright (c) 2015 zane. All rights reserved.
//

#import "ZNCemeraView.h"




@implementation ZNCemeraView {
    int frameCounter;
    NSMutableData *buffer1;
    NSMutableData *buffer2;
    NSMutableData *currentData;
    UIImage *currentFrame;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initViewWithFrame:(CGRect)frame{
    if (self = [super init]) {
        
        self.frame = frame ;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://192.168.1.1:8080/?action=stream"]
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
        NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        if (connection) {
            currentData = [[NSMutableData alloc] init];
        }
        
       
    }
    return self ;
}


- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
    [currentData appendData:data];
}



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if([[response MIMEType] isEqualToString:@"image/jpeg"] && [currentData length] != 0) {
        currentFrame = [UIImage imageWithData:currentData];
        [self setImage:currentFrame];
    }
    [currentData setLength:0];
}


@end
