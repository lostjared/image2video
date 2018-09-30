
#import<Foundation/Foundation.h>
#import<Cocoa/Cocoa.h>
#undef check
#include<opencv2/videoio.hpp>
#include<opencv2/imgproc.hpp>
#include<opencv2/highgui.hpp>


@interface Controller : NSObject {
    IBOutlet NSButton *add_files, *remove_file, *move_file_up, *move_file_down, *build_video, *stretch_video;
    IBOutlet NSTableView *table_view;
    IBOutlet NSTextView  *text_log;
    IBOutlet NSTextField *field_fps, *field_w, *field_h;
}

- (IBAction) buildVideo: (id) sender;

@end

