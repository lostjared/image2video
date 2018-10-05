
#include"CV.hpp"
#include<iostream>
#import "TableView.h"

@implementation TableController

@synthesize file_values;

- (void) createValues {
    file_values = [[NSMutableArray alloc] init];
    
}
- (id) tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
    NSString *str =  [[aTableColumn headerCell] stringValue];
    if( [str isEqualTo:@"Index"] ) {
        NSString *s = [NSString stringWithFormat:@"%d",  (int)rowIndex, nil];
        return s;
    }
    else if([str isEqualTo:@"Image Path"]) {
        return [file_values objectAtIndex: rowIndex];
    }
    return @"";
}

- (void)tableView:(NSTableView *)tableView didClickedRow:(NSInteger)row {
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
    return [file_values count];
}

- (void) addFile:(NSString *)filename {
    [file_values addObject:filename];
}
- (void) removeIndex: (NSInteger)index {
    [file_values removeObjectAtIndex:index];
}
- (void) clearList {
    [file_values removeAllObjects];
}

- (void) moveUp: (NSInteger) index {
    if(index > 0) {
        NSInteger pos = index-1;
        id obj = [file_values objectAtIndex:pos];
        id mv = [file_values objectAtIndex:index];
        [file_values setObject:obj atIndexedSubscript:index];
        [file_values setObject:mv atIndexedSubscript: pos];
    }
}
- (void) moveDown: (NSInteger) index {
    if(index < [file_values count]-1) {
        NSInteger pos = index+1;
        id obj = [file_values objectAtIndex:pos];
        id mv = [file_values objectAtIndex:index];
        [file_values setObject:obj atIndexedSubscript:index];
        [file_values setObject:mv atIndexedSubscript: pos];
    }
}

- (void) showImage:(NSInteger)row {
    cv::namedWindow("image2video");
    NSString *s = [file_values objectAtIndex:row];
    cv::Mat img = cv::imread([s UTF8String]);
    if(img.empty()) {
        std::cerr << "Error could not open image file...\n";
        return;
    }
    cv::Mat display_image = resizeKeepAspectRatio(img, cv::Size(640, 480), cv::Scalar(0, 0, 0));
    cv::imshow("image2video", display_image);
}

@end

@implementation TableView

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint globalLocation = [theEvent locationInWindow];
    NSPoint localLocation = [self convertPoint:globalLocation fromView:nil];
    NSInteger clickedRow = [self rowAtPoint:localLocation];
    [super mouseDown:theEvent];
    if(clickedRow != -1) {
        id dl = [self delegate];
        [dl showImage:clickedRow];
    }
}

@end

