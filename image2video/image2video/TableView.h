
#import<Cocoa/Cocoa.h>

@interface TableController : NSObject<NSTableViewDataSource, NSTableViewDelegate> {
}
@property (readwrite) NSMutableArray *file_values;
- (void) createValues;
- (void) addFile:(NSString *)filename;
- (void) removeIndex: (NSInteger)index;
- (void) clearList;
- (void) moveUp: (NSInteger) index;
- (void) moveDown: (NSInteger) index;
- (void) showImage: (NSInteger) row;
@end


@interface TableView : NSTableView {
    
}

@end
