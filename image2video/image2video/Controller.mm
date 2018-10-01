
#include<opencv2/videoio.hpp>
#import "Controller.h"
#include<cstdio>
#include<cstdlib>
#include<cmath>
#include<iostream>


@implementation Controller

- (void)awakeFromNib {
    table_controller = [[TableController alloc] init];
    [table_controller createValues];
    [table_view setDelegate:table_controller];
    [table_view setDataSource:table_controller];
    [table_view reloadData];
}

- (IBAction) buildVideo: (id) sender {
    double fps_value = 0,width_value = 0, height_value = 0;
    if([self checkInput:&fps_value width:&width_value height:&height_value] == NO)
        return;
    
    //NSInteger stretch_image = [stretch_video integerValue];
    // if stretch_image == NSOnState
    
    
    cv::VideoWriter writer;
}

- (BOOL) checkInput: (double *)fps_value width:(double *)width_value height:(double *)height_value {
    *fps_value = atof([[field_fps stringValue] UTF8String]);
    if(*fps_value<= 0 || *fps_value > 60) {
        _NSRunAlertPanel(@"FPS value is incorrect", @"Please use a valid frames per second value", @"Ok", nil, nil);
        *fps_value = 0;
        *width_value = 0;
        *height_value = 0;
        return NO;
    }
    *width_value = atof([[field_w stringValue] UTF8String]);
    if(*width_value <= 0 || *width_value > 3840) {
        _NSRunAlertPanel(@"Enter valid frame width", @"Please use a valid frame width variable", @"Ok", nil, nil);
        *fps_value = 0;
        *width_value = 0;
        *height_value = 0;
        return NO;
    }
    *height_value = atof([[field_h stringValue] UTF8String]);
    if(*height_value <= 0 || *height_value > 2160) {
        _NSRunAlertPanel(@"Enter valid frame height", @"Please use a valid frame height variable", @"Ok", nil, nil);
        *fps_value = 0;
        *width_value = 0;
        *height_value = 0;
        return NO;
    }
    return YES;
}

- (IBAction) addFiles: (id) sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setAllowsMultipleSelection:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowedFileTypes: [NSArray arrayWithObjects: @"png", @"jpg", @"bmp", nil]];
    if([panel runModal]) {
        NSInteger count = [[panel URLs] count];
        for(NSInteger i = 0; i < count; ++i) {
            NSURL *u = [[panel URLs] objectAtIndex:i];
            [table_controller addFile: [u path]];
        }
        [table_view reloadData];
    }
}

- (IBAction) rmvFiles: (id) sender {
    NSInteger row = [table_view selectedRow];
    if(row >= 0) {
        [table_controller removeIndex:row];
        [table_view reloadData];
    }
}

- (IBAction) moveUp: (id) sender {
    NSInteger index = [table_view selectedRow];
    [table_controller moveUp:index];
    [table_view reloadData];
}

- (IBAction) moveDown: (id) sender {
    NSInteger index = [table_view selectedRow];
    [table_controller moveDown: index];
    [table_view reloadData];
}

- (IBAction) clearList: (id) sender {
    [table_controller clearList];
    [table_view reloadData];
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
