
#import<Cocoa/Cocoa.h>

@interface TableController : NSObject<NSTableViewDataSource, NSTableViewDelegate> {
     NSMutableArray *file_values;
}

- (void) createValues;
- (void) addFile:(NSString *)filename;
- (void) removeIndex: (NSInteger)index;

@end
