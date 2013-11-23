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
        //[listOutlineView registerForDraggedTypes:[NSArray arrayWithObjects:FWK_PASTEBOARD_TYPE, nil]];
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
        if(index == NSNotFound){
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
        if(index == NSNotFound){
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
/*
- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint forItems:(NSArray *)draggedItems {
    draggingItemList = draggedItems;
    [session.draggingPasteboard setData:[NSData data] forType:FWK_PASTEBOARD_TYPE];
}

- (void)outlineView:(NSOutlineView *)outlineView draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation {
    // If the session ended in the trash, then delete all the items
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
    
    draggingItemList = nil;
}
*/
@end
