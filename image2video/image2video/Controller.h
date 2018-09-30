
#import<Cocoa/Cocoa.h>

@interface Controller : NSObject {
    IBOutlet NSButton *add_files, *remove_file, *move_file_up, *move_file_down, *build_video, *stretch_video;
    IBOutlet NSTableView *table_view;
    IBOutlet NSTextView  *text_log;
    IBOutlet NSTextField *field_fps, *field_w, *field_h;
    double fps_value, width_value, height_value;
}

- (IBAction) buildVideo: (id) sender;
- (BOOL) checkInput;

@end

NSInteger _NSRunAlertPanel(NSString *msg1, NSString *msg2, NSString *button1, NSString *button2, NSString *button3);
