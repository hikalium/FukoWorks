//
//  CanvasObjectListWindowController.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/10/13.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectListWindowController.h"
#import "CanvasObject.h"

@interface CanvasObjectListWindowController ()

@end

@implementation CanvasObjectListWindowController

@synthesize currentCanvas = _currentCanvas;
- (void)setCurrentCanvas:(MainCanvasView *)currentCanvas
{
    _currentCanvas = currentCanvas;
    //[canvasObjectArrayController setContent:currentCanvas.subviews];
    [self reloadData];
}

- (id)init
{
    self = [super initWithWindowNibName:[self className]];
    
    if(self){
        
    }
    
    return self;
}

CanvasObjectListWindowController *_sharedCanvasObjectListWindowController = nil;
+ (CanvasObjectListWindowController *)sharedCanvasObjectListWindowController
{
    if(_sharedCanvasObjectListWindowController == nil) {
        _sharedCanvasObjectListWindowController = [[CanvasObjectListWindowController alloc] init];
    }
    return _sharedCanvasObjectListWindowController;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [listPanel setReleasedWhenClosed:NO];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [listOutlineView registerForDraggedTypes:[NSArray arrayWithObjects:FWK_PASTEBOARD_TYPE, nil]];
}

- (void)showWindow:(id)sender
{
    [super showWindow:sender];
    listPanel.isVisible = YES;
}

- (void)reloadData
{
    [listOutlineView reloadData];
}

- (void)selectCanvasObject: (CanvasObject *)co byExtendingSelection:(BOOL)ext
{
    NSIndexSet *indexSet;
    if(co){
        NSArray *list = [[_currentCanvas.canvasObjects reverseObjectEnumerator] allObjects];
        indexSet = [NSIndexSet indexSetWithIndex:[list indexOfObject:co]];
    } else{
        indexSet = [NSIndexSet indexSet];
    }
    [listOutlineView selectRowIndexes:indexSet byExtendingSelection:ext];
}

- (IBAction)bringFront:(id)sender {
    if(_currentCanvas){
        NSInteger index = [listOutlineView selectedRow];
        if(index == -1){
            return;
        }
        NSArray *list = [[_currentCanvas.canvasObjects reverseObjectEnumerator] allObjects];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index - 1];
        if([_currentCanvas bringCanvasObjectToFront:[list objectAtIndex:index]]){
            [listOutlineView selectRowIndexes:indexSet byExtendingSelection:NO];
            [self reloadData];
        }
    }
}

- (IBAction)bringBack:(id)sender {
    if(_currentCanvas){
        NSInteger index = [listOutlineView selectedRow];
        if(index == -1){
            return;
        }
        NSArray *list = [[_currentCanvas.canvasObjects reverseObjectEnumerator] allObjects];
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index + 1];
        if([_currentCanvas bringCanvasObjectToBack:[list objectAtIndex:index]]){
            [listOutlineView selectRowIndexes:indexSet byExtendingSelection:NO];
            [self reloadData];
        }
    }
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    //NSLog(@"numberOfChildrenOfItem %@", item);
    if(item == nil){
        return _currentCanvas.canvasObjects.count;
    }
    return 0;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    //NSLog(@"isItemExpandable %@", item);
    return (item == nil) ? YES : NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldTrackCell:(NSCell *)cell forTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    return (item == nil) ? YES : NO;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    //NSLog(@"child ofItem %@ %ld", item, (long)index);
    if(item == nil){
        return [[[_currentCanvas.canvasObjects reverseObjectEnumerator] allObjects] objectAtIndex:index];
    }
    
    return nil;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    //NSLog(@"objectValueForTableColumn %@ %@", tableColumn.identifier, item);
    NSString *ident = tableColumn.identifier;
    if([item isKindOfClass:[CanvasObject class]]){
        //NSLog(@"p");
        CanvasObject *co = (CanvasObject *)item;
        if([ident isEqualToString:@"Name"]){
            return [co objectName];
        } else if([ident isEqualToString:@"Type"]){
            return [co ObjectTypeName];
        } else if([ident isEqualToString:@"Origin"]){
            return NSStringFromPoint(co.frame.origin);
        } else if([ident isEqualToString:@"Size"]){
            return NSStringFromSize(co.frame.size);
        }
    }
    return @"???";
}

//
// Drag and Drop function
//

- (id <NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item
{
    //1
    //NSLog(@"writer");
    // With all the blocking conditions out of the way,
    // return a pasteboard writer.
    
    NSPasteboardItem *pboardItem = [[NSPasteboardItem alloc] init];
    
    //[pboardItem setString:@"abc" forType: FWK_PASTEBOARD_TYPE];
    [pboardItem setData:[NSData data] forType:FWK_PASTEBOARD_TYPE];
    
    
    return pboardItem;
}

- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray *)draggedItems {
    //2
    //NSLog(@"sessionstart");
    draggingItemList = draggedItems;
    [session.draggingPasteboard setData:[NSData data] forType:FWK_PASTEBOARD_TYPE];
}

- (NSDragOperation)outlineView:(NSOutlineView *)outlineView validateDrop:(id < NSDraggingInfo >)info proposedItem:(id)item proposedChildIndex:(NSInteger)index
{
    //retv:
    //NSDragOperationNone:なにもしない
    //NSDragOperationMove:間に入れることも、重ねていれることもできる
    //あるアイテムがドラッグを受け付けるかどうかを教えてあげる
    //NSLog(@"validate");
    return (item == nil) ? NSDragOperationMove : NSDragOperationNone;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView acceptDrop:(id < NSDraggingInfo >)info item:(id)item childIndex:(NSInteger)index
{
    //NSLog(@"accept %@ %ld", item, index);
    // Move the dragged item(s) to their new position in the data model
    // and reload the view or move the rows in the view.
    // This is of course quite dependent on your implementation
    NSArray *list = [[_currentCanvas.canvasObjects reverseObjectEnumerator] allObjects];
    CanvasObject *coBelow = nil;
    if(index < list.count){
        coBelow = [list objectAtIndex:index];
    }
    [_currentCanvas moveCanvasObjects:draggingItemList aboveOf:coBelow];
    [self reloadData];
    
    return YES;
}

- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    //NSLog(@"sessionend");
    // If the session ended in the trash, then delete all the items
    /*
    if (operation == NSDragOperationDelete) {
        [outlineView beginUpdates];
        
        [draggingItemList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id node, NSUInteger index, BOOL *stop) {
            id parent = [node parentNode];
            NSMutableArray *children = [parent mutableChildNodes];
            NSInteger childIndex = [children indexOfObject:node];
            [children removeObjectAtIndex:childIndex];
            //[outlineView removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:childIndex] inParent:parent == outlineView. ? nil : parent withAnimation:NSTableViewAnimationEffectFade];
        }];
        
        [outlineView endUpdates];
    }
     */
    
    draggingItemList = nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    // itemはCanvasObjectであるはず
    /*
    CanvasObject *lastSelectedCanvasObject;
    lastSelectedCanvasObject = [outlineView itemAtRow:[outlineView selectedRow]];
    if(lastSelectedCanvasObject){
        
    }
     */
    if([item isKindOfClass:[CanvasObject class]]){
        [self.currentCanvas deselectAllCanvasObject];
        [self.currentCanvas selectCanvasObject:item];
    }
    
    return YES;
}
@end
