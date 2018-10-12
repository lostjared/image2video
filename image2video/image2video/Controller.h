
#import<Cocoa/Cocoa.h>
#import "TableView.h"

@interface Controller : NSObject {
    IBOutlet NSButton *add_files, *remove_file, *move_file_up, *move_file_down, *build_video, *stretch_video, *clear_button, *scan_button, *scan_dir_button;
    IBOutlet NSButton *radio_search, *radio_match, *radio_byframe, *radio_bysecond;
    IBOutlet TableView *table_view;
    IBOutlet NSTextView  *text_log;
    IBOutlet NSTextField *field_fps, *field_w, *field_h, *reg_text, *video_info;
    IBOutlet NSWindow *scan_window;
    IBOutlet NSProgressIndicator *scan_progress, *extract_progress;
    IBOutlet NSWindow *extract_win;
    IBOutlet NSTextField *extract_filename_label, *extract_prefix;
    IBOutlet NSButton *extract_select, *extract_output, *extract_show;
    IBOutlet NSMenuItem *menu_select;
    double fps_value, width_value, height_value;
}

@property (readwrite) TableController *table_controller;
@property (readwrite) BOOL quitLoop;
@property (readwrite) BOOL quitExtractLoop;
- (IBAction) buildVideo: (id) sender;
- (BOOL) checkInput: (double *)fps width:(double *)w height:(double *)h;
- (IBAction) addFiles: (id) sender;
- (IBAction) rmvFiles: (id) sender;
- (IBAction) moveUp: (id) sender;
- (IBAction) moveDown: (id) sender;
- (IBAction) clearList: (id) sender;
- (IBAction) scanDir: (id) sender;
- (void) flushToLog: (NSString*) str;
- (void) enableControls;
- (IBAction) radioClicked: (id) sender;
- (IBAction) scanDirectories: (id) sender;
- (IBAction) showExtractWindow: (id) sender;
- (IBAction) setShowImage:(id) sender;
- (IBAction) extractSelectFile: (id) sender;
- (IBAction) extractFile: (id) sender;
- (IBAction) setFilenameRadio: (id) sender;
- (IBAction) updateInfoLabel: (id) sender;
@end

NSInteger _NSRunAlertPanel(NSString *msg1, NSString *msg2, NSString *button1, NSString *button2, NSString *button3);
