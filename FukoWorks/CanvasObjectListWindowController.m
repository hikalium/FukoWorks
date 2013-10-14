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
    [_sharedCanvasObjectListWindowController showWindow:nil];
    return _sharedCanvasObjectListWindowController;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)reloadData
{
    [outlineView reloadData];
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


@end
