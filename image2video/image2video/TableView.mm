/*
 
 Written by Jared Bruni - http://github.com/lostjared
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.
 
*/

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

@synthesize imageShown;

- (void) awakeFromNib {
    imageShown = YES;
}

- (void)mouseDown:(NSEvent *)event {
    NSPoint location = [event locationInWindow];
    NSPoint local = [self convertPoint:location fromView:nil];
    NSInteger clicked = [self rowAtPoint:local];
    [super mouseDown:event];
    if(clicked != -1 && imageShown == YES) {
        id dl = [self delegate];
        [dl showImage:clicked];
    }
}

@end

