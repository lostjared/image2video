
#import "TableView.h"


@implementation TableController

- (void) createValues {
    file_values = [[NSMutableArray alloc] init];
    
}
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
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


@end
