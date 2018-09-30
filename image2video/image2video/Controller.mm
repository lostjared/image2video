
#import<Cocoa/Cocoa.h>
#undef check

#include<opencv2/videoio.hpp>
#import "Controller.h"

#include<cstdio>
#include<cstdlib>
#include<cmath>

@implementation Controller

- (IBAction) buildVideo: (id) sender {
    
    fps_value = width_value = height_value = 0;
    if([self checkInput] == NO)
        return;
    
    cv::VideoWriter writer;
    
}

- (BOOL) checkInput {
    fps_value = atof([[field_fps stringValue] UTF8String]);
    if(fps_value<= 0 || fps_value > 60) {
        _NSRunAlertPanel(@"FPS value is incorrect", @"Please use a valid frames per second value", @"Ok", nil, nil);
        return NO;
    }
    width_value = atof([[field_w stringValue] UTF8String]);
    if(width_value <= 0 || width_value > 3840) {
        _NSRunAlertPanel(@"Enter valid frame width", @"Please use a valid frame width variable", @"Ok", nil, nil);
        return NO;
    }
    height_value = atof([[field_h stringValue] UTF8String]);
    if(height_value <= 0 || width_value > 2160) {
        _NSRunAlertPanel(@"Enter valid frame height", @"Please use a valid frame height variable", @"Ok", nil, nil);
        return NO;
    }
    return YES;
}

@end

NSInteger _NSRunAlertPanel(NSString *msg1, NSString *msg2, NSString *button1, NSString *button2, NSString *button3) {
    NSAlert *alert = [[NSAlert alloc] init];
    if(button1 != nil) [alert addButtonWithTitle:button1];
    if(button2 != nil) [alert addButtonWithTitle:button2];
    if(msg1 != nil) [alert setMessageText:msg1];
    if(msg2 != nil) [alert setInformativeText:msg2];
    NSInteger rt_val = [alert runModal];
    return rt_val;
}
