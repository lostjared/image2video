

#include"CV.hpp"
#import "Controller.h"
#include<cstdio>
#include<cstdlib>
#include<cmath>
#include<iostream>
#include<regex>
#include<vector>
#include<string>
#include<sstream>
#include<dirent.h>
#include<sys/types.h>
#include<sys/stat.h>


void scanDirectoriesRegEx(std::string dir_path, std::string regex, int mode, std::vector<std::string> &paths);

@implementation Controller

@synthesize table_controller;
@synthesize quitLoop;
@synthesize quitExtractLoop;

- (void)awakeFromNib {
    table_controller = [[TableController alloc] init];
    [table_controller createValues];
    [table_view setDelegate:table_controller];
    [table_view setDataSource:table_controller];
    [table_view reloadData];
    quitLoop = NO;
    quitExtractLoop = NO;
}

- (IBAction) buildVideo: (id) sender {
    
    cv::destroyWindow("image2video");
    
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
            [scan_window orderOut:self];
            [extract_win orderOut:self];
            NSString *fileName = [[panel URL] path];
            [add_files setEnabled:NO];
            [remove_file setEnabled:NO];
            [move_file_up setEnabled:NO];
            [move_file_down setEnabled:NO];
            [stretch_video setEnabled:NO];
            [clear_button setEnabled:NO];
            [scan_button setEnabled:NO];
            [build_video setTitle:@"Stop"];
            [extract_show setEnabled:NO];
            [extract_output setEnabled:NO];
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
                            [self flushToLog: @"Stopped processing video...\n"];
                            [self enableControls];
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
    [panel setAllowedFileTypes: [NSArray arrayWithObjects: @"bmp",@"dib",@"png",@"jpg",@"pbm", @"pgm", @"ppm", @"sr", @"ras", @"tiff", nil]];
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
    [table_view deselectAll:self];
    [table_view reloadData];
}

- (IBAction) moveDown: (id) sender {
    NSInteger index = [table_view selectedRow];
    [table_controller moveDown: index];
    [table_view deselectAll:self];
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
    [build_video setTitle:@"Build"];
    [extract_show setEnabled:YES];
    [extract_output setEnabled:YES];
}

- (IBAction) radioClicked: (id) sender {
    
}

- (IBAction) scanDirectories: (id) sender {
    NSString *r = [reg_text stringValue];
    if([r length] <= 0) {
        _NSRunAlertPanel(@"Error requires Regular Expression", @"You need to put a Regular Expression in the text box", @"Ok", nil, nil);
        return;
    }
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO];
    if([panel runModal]) {
        [scan_button setEnabled:NO];
        NSString *s = [[panel URL] path];
        int mode = 0;
        if([radio_match integerValue] == NSOnState)
            mode = 0;
        else if([radio_search integerValue] == NSOnState)
            mode = 1;
        [scan_dir_button setEnabled:NO];
        [scan_progress startAnimation:self];
        NSButton *scan_ = scan_dir_button;
        NSTableView *table_view_ = table_view;
        NSProgressIndicator *scan_prog = scan_progress;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            std::vector<std::string> vfound;
            scanDirectoriesRegEx([s UTF8String], [r UTF8String], mode, vfound);
            if(vfound.size()>0) {
                for(int i = 0; i < vfound.size(); ++i) {
                    NSString *str = [NSString stringWithUTF8String: vfound[i].c_str()];
                    [self.table_controller.file_values addObject: str];
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [scan_ setEnabled:YES];
                    [table_view_ reloadData];
                    [scan_prog stopAnimation:self];
                });
            }
        });
    }
}

- (IBAction) showExtractWindow: (id) sender {
    [extract_win orderFront:self];
}

- (IBAction) setShowImage:(id) sender {
    if([menu_select state] == NSOnState) {
        [menu_select setState:NSOffState];
        [table_view setImageShown:NO];
    } else {
        [menu_select setState:NSOnState];
        [table_view setImageShown:YES];
    }
}

- (IBAction) extractSelectFile: (id) sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO];
    [panel setAllowedFileTypes: [NSArray arrayWithObjects:@"mov", @"avi", @"mp4", @"mkv",nil]];
    if([panel runModal]) {
        NSString *s = [[panel URL] path];
        [extract_filename_label setStringValue:s];
    }
}

- (IBAction) extractFile: (id) sender {
    
    if([[extract_prefix stringValue] length] <= 0) {
        _NSRunAlertPanel(@"Error requires filename prefix", @"FIll in the Textbox", @"Ok", nil, nil);
        return;
    }
    
    if ([[extract_output title] isEqualToString:@"Extract Frames"]) {
        
        NSString *fileName = [extract_filename_label stringValue];
        NSString *prefix = [extract_prefix stringValue];
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setCanCreateDirectories:YES];
        [panel setCanChooseDirectories:YES];
        [panel setCanChooseFiles:NO];
        NSString *dir_output = nil;
        if([panel runModal]) {
            dir_output = [[panel URL] path];
        } else
            return;
        if([fileName length] > 0) {
            [extract_output setTitle:@"Stop"];
            [build_video setEnabled:NO];
            NSButton *e_output = extract_output;
            NSButton *b_output = build_video;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                cv::VideoCapture cap([fileName UTF8String]);
                if(!cap.isOpened()) {
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        _NSRunAlertPanel(@"Could not open file", @"Error could not open file", @"Ok", nil, nil);
                        return;
                    });
                }
                cv::Mat frame;
                long count = (long) cap.get(CV_CAP_PROP_FRAME_COUNT);
                long image_index = 0;
                std::ostringstream stream;
                stream << count;
                long stream_count = stream.str().length();
                while(cap.read(frame)) {
                    std::ostringstream index;
                    index.width(stream_count+1);
                    index.fill('0');
                    index << image_index+1;
                    NSString *file_output = [NSString stringWithFormat:@"%@/%@.%s.png", dir_output,prefix,index.str().c_str()];
                    cv::imwrite([file_output UTF8String], frame);
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        [self flushToLog: [NSString stringWithFormat:@"Extraction Wrote file: %@ [%ld/%ld]\n", file_output, (image_index+1),count]];
                    });
                    ++image_index;
                    if([self quitExtractLoop] == YES) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [e_output setTitle:@"Extract Frames"];
                            [self flushToLog:@"Stopped Extraction Loop"];
                            [self setQuitExtractLoop:NO];
                        });
                        return;
                    }
                }
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [e_output setTitle:@"Extract Frames"];
                    [b_output setEnabled:YES];
                });
                
            });
        } else {
            _NSRunAlertPanel(@"Please select directory to output files to...\n", @"Select Directory", @"Ok", nil, nil);
            return;
        }
    } else {
        [self setQuitExtractLoop:YES];
    }
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

void scanDirectoriesRegEx(std::string path, std::string regex_str, int mode, std::vector<std::string> &files) {
    DIR *dir = opendir(path.c_str());
    if(dir == NULL) {
        std::cerr << "Error could not open directory: " << path << "\n";
        return;
    }
    dirent *file_info;
    while( (file_info = readdir(dir)) != 0 ) {
        std::string f_info = file_info->d_name;
        if(f_info == "." || f_info == "..")  continue;
        std::string fullpath=path+"/"+f_info;
        struct stat s;
        lstat(fullpath.c_str(), &s);
        if(S_ISDIR(s.st_mode)) {
            if(f_info.length()>0 && f_info[0] != '.')
                scanDirectoriesRegEx(path+"/"+f_info,regex_str,mode,files);
            continue;
        }
        if(f_info.length()>0 && f_info[0] != '.') {
            std::regex r(regex_str);
            bool is_valid;
            if(mode == 0)
                is_valid = std::regex_match(f_info, r);
            else
                is_valid = std::regex_search(f_info, r);
            
            if(is_valid)
                files.push_back(fullpath);
        }
    }
    closedir(dir);
}
