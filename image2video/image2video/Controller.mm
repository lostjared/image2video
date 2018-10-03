
#include<opencv2/videoio.hpp>
#include<opencv2/imgproc.hpp>
#include<opencv2/highgui.hpp>

#import "Controller.h"
#include<cstdio>
#include<cstdlib>
#include<cmath>
#include<iostream>

cv::Mat resizeKeepAspectRatio(const cv::Mat &input, const cv::Size &dstSize, const cv::Scalar &bgcolor);

@implementation Controller

@synthesize table_controller;
@synthesize quitLoop;

- (void)awakeFromNib {
    table_controller = [[TableController alloc] init];
    [table_controller createValues];
    [table_view setDelegate:table_controller];
    [table_view setDataSource:table_controller];
    [table_view reloadData];
    quitLoop = NO;
}

- (IBAction) buildVideo: (id) sender {
    if([[build_video title] isEqualToString:@"Stop"]) {
        [self setQuitLoop: YES];
        [build_video setTitle:@"Build"];
        return;
    } else if([[build_video title] isEqualToString: @"Build"]) {
        double fps_value = 0,width_value = 0, height_value = 0;
        if([self checkInput:&fps_value width:&width_value height:&height_value] == NO)
            return;
        
        if([table_controller.file_values count] < fps_value) {
            _NSRunAlertPanel(@"Requires some image files to produce a video", @"Not enough files", @"Ok", nil, nil);
            return;
        }
        NSInteger stretch_image = [stretch_video integerValue];
        NSSavePanel *panel = [NSSavePanel savePanel];
        [panel setCanCreateDirectories:YES];
        [panel setAllowedFileTypes: [NSArray arrayWithObject:@"mov"]];
        [panel setAllowsOtherFileTypes:NO];
        [self setQuitLoop:NO];
        if([panel runModal]) {
            NSString *fileName = [[panel URL] path];
            NSLog(@"Write to file: %@\n", fileName);
            [add_files setEnabled:NO];
            [remove_file setEnabled:NO];
            [move_file_up setEnabled:NO];
            [move_file_down setEnabled:NO];
            [stretch_video setEnabled:NO];
            [clear_button setEnabled:NO];
            [scan_button setEnabled:NO];
            [build_video setTitle:@"Stop"];
            quitLoop = NO;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                cv::VideoWriter writer;
                if(!writer.open([fileName UTF8String],CV_FOURCC('m', 'p', '4', 'v'), fps_value, cv::Size(width_value, height_value), true)) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self flushToLog: [NSString stringWithFormat:@"Could not create Video Writer with file: %@\n", fileName]];
                        [self enableControls];
                    });
                    return;
                }
                cv::Mat frame, image;
                for(NSInteger i = 0; i < [self.table_controller.file_values count]; ++i) {
                    if([self quitLoop] == YES) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self flushToLog: @"Stopping...\n"];;
                        });
                        return;
                    }
                    
                    NSString *file_n = [self.table_controller.file_values objectAtIndex: i];
                    frame = cv::imread([file_n UTF8String]);
                    if(frame.empty()) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self flushToLog: [NSString stringWithFormat:@"Could not open file: %@ skipping...\n", file_n]];
                        });
                        continue;
                    }
                    
                    if(stretch_image == NSOnState)
                        cv::resize(frame, image, cv::Size(width_value, height_value));
                    else
                        image = resizeKeepAspectRatio(frame, cv::Size(width_value, height_value), cv::Scalar(0,0,0));
                    
                    writer.write(image);
                    
                    float val = i+1;
                    float size = [self.table_controller.file_values count];
                    float percent_complete = 0;
                    if(size != 0)
                        percent_complete = (val/size)*100;
                    
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self flushToLog: [NSString stringWithFormat:@"Wrote frame [%ld/%ld] - %d%% \n", (long)(i+1), (long)[self.table_controller.file_values count], (int)percent_complete]];;
                    });
                }
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [self flushToLog: [NSString stringWithFormat:@"100%% - Completed wrote to file: %@\n",fileName]];
                    [self enableControls];
                });
                writer.release();
            });
        }
    }
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

- (IBAction) scanDir: (id) sender {
    [scan_window orderFront: self];
}

- (void) flushToLog: (NSString *) val {
    NSTextView *sv = text_log;
    NSString *value = [[sv textStorage] string];
    NSString *newValue = [[NSString alloc] initWithFormat: @"%@%@", value, val];
    [sv setString: newValue];
    [sv scrollRangeToVisible:NSMakeRange([[sv string] length], 0)];
}

- (void) enableControls {
    [add_files setEnabled:YES];
    [remove_file setEnabled:YES];
    [move_file_up setEnabled:YES];
    [move_file_down setEnabled:YES];
    [stretch_video setEnabled:YES];
    [clear_button setEnabled:YES];
    [scan_button setEnabled:YES];
}

- (IBAction) radioClicked: (id) sender {
    
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

cv::Mat resizeKeepAspectRatio(const cv::Mat &input, const cv::Size &dstSize, const cv::Scalar &bgcolor) {
    cv::Mat output;
    double h1 = dstSize.width * (input.rows/(double)input.cols);
    double w2 = dstSize.height * (input.cols/(double)input.rows);
    if(h1 <= dstSize.height)
        cv::resize(input, output, cv::Size(dstSize.width, h1));
    else
        cv::resize(input, output, cv::Size(w2, dstSize.height));
    int top = (dstSize.height-output.rows)/2;
    int down = (dstSize.height-output.rows+1)/2;
    int left = (dstSize.width - output.cols)/2;
    int right = (dstSize.width - output.cols+1)/2;
    cv::copyMakeBorder(output, output, top, down, left, right, cv::BORDER_CONSTANT, bgcolor);
    return output;
}

