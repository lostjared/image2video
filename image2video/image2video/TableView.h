
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

@property (readwrite) BOOL imageShown;

@end
