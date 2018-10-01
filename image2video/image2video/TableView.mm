
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



@end
