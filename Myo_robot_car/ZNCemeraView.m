//
//  ZNCemeraView.m
//  Myo_robot_car
//
//  Created by zane on 10/22/15.
//  Copyright (c) 2015 zane. All rights reserved.
//

#import "ZNCemeraView.h"

@implementation ZNCemeraView

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
        
        NSString *embedHTML = @"\
        <html><head>\
        <style type=\"text/css\">\
        body {\
        background-color: transparent;\
        color: black;\
        }\
        </style>\
        </head><body style=\"margin:0\">\
        <embed id=\"yt\" src=\"http://192.168.1.1:8080/?action=stream \" style=\"-webkit-user-select: none\" \
        width=640 height=480 ></embed>\
        </body></html>";
        
        
        [self loadHTMLString:embedHTML baseURL:nil];
    }
    return self ;
}



@end
