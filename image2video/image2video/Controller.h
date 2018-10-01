
#import<Cocoa/Cocoa.h>
#import "TableView.h"

@interface Controller : NSObject {
    IBOutlet NSButton *add_files, *remove_file, *move_file_up, *move_file_down, *build_video, *stretch_video;
    IBOutlet NSTableView *table_view;
    IBOutlet NSTextView  *text_log;
    IBOutlet NSTextField *field_fps, *field_w, *field_h;
    double fps_value, width_value, height_value;
}

@property (readwrite) TableController *table_controller;

- (IBAction) buildVideo: (id) sender;
- (BOOL) checkInput: (double *)fps width:(double *)w height:(double *)h;
- (IBAction) addFiles: (id) sender;
- (IBAction) rmvFiles: (id) sender;
- (IBAction) moveUp: (id) sender;
- (IBAction) moveDown: (id) sender;
- (IBAction) clearList: (id) sender;
- (void) flushToLog: (NSString*) str;
- (void) enableControls;

@end

NSInteger _NSRunAlertPanel(NSString *msg1, NSString *msg2, NSString *button1, NSString *button2, NSString *button3);
