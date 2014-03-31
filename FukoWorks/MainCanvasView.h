//
//  MainCanvasView.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToolboxController.h"
#import "InspectorWindowController.h"
#import "CanvasObject.h"
#import "CanvasObjectRectangle.h"
#import "CanvasObjectEllipse.h"
#import "CanvasObjectPaintFrame.h"
#import "CanvasObjectTextBox.h"
#import "CanvasObjectLine.h"
#import "SubCanvasView.h"
#import "CanvasObjectHandle.h"

@interface MainCanvasView : NSView
{
    NSUndoManager *undoManager;
    
    SubCanvasView *rootSubCanvas;
    
    NSPoint drawingStartPoint;
    NSPoint drawingDragPoint;
    
    CGColorRef backgroundColor;
    
    CanvasObject *creatingObject;
    
    CanvasObject *movingObject;
    NSPoint moveHandleOffset;
    
    CanvasObject *editingObject;
    CanvasObjectPaintFrame *editingPaintFrame;
    
    NSMutableArray *inspectorWindows;
    
    NSMutableDictionary *objectHandles;
    NSMutableArray *selectedObjects;
    
    CanvasObject *rightClickedObject;
    NSPoint rightClickedLocationInScreen;
}

@property (strong, nonatomic) NSTextField *label_indicator;
@property (nonatomic) ToolboxController *toolboxController;
@property (nonatomic) CGFloat canvasScale;
@property (nonatomic) NSSize canvasSize;
@property (nonatomic, readonly) NSMutableArray *canvasObjects;
@property (nonatomic, readonly) NSView *realSizeCanvas;
@property (nonatomic, readonly) NSArray *selectedObjectList;

- (id)initWithFrame:(NSRect)frame;
- (void)drawRect:(NSRect)dirtyRect;

- (void)resetCursorRects;

- (void)addCanvasObject:(CanvasObject *)aCanvasObject;
- (void)removeCanvasObject:(CanvasObject *)aCanvasObject;
- (void)removeCanvasObjects:(NSArray *)canvasObjectList;

- (NSRect)getVisibleRectOnObjectLayer;
- (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint;
- (NSPoint)getPointerLocationRelativeToSelfView:(NSEvent*)event;
- (NSPoint)getPointerLocationInScreen:(NSEvent *)event;
- (CanvasObject *)getCanvasObjectAtCursorLocation:(NSEvent *)event;
- (CanvasObject *)getCanvasObjectAtCursorLocationOnCanvas:(NSPoint)currentPointOnCanvas;

- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)cut:(id)sender;
- (IBAction)delete:(id)sender;

@end

@interface MainCanvasView (CanvasObjectSelection)
- (void)selectCanvasObject:(CanvasObject *)aCanvasObject;
- (void)resetCanvasObjectHandleForCanvasObject:(CanvasObject *)aCanvasObject;
- (void)resetAllCanvasObjectHandle;
- (void)hideCanvasObjectHandleForCanvasObject:(CanvasObject *)aCanvasObject;
- (void)showCanvasObjectHandleForCanvasObject:(CanvasObject *)aCanvasObject;
- (void)deselectCanvasObject:(CanvasObject *)aCanvasObject;
- (void)deselectAllCanvasObject;
- (void)deselectAllCanvasObjectExceptFor:(CanvasObject *)obj;
- (BOOL)isSelectedCanvasObject:(CanvasObject *)aCanvasObject;
- (void)checkEditingObject;
@end

@interface MainCanvasView (UndoManaging)
- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;
@end

@interface MainCanvasView (Printing)
- (NSSize)calculatePrintPaperSize;
- (BOOL)knowsPageRange:(NSRangePointer)range;
- (NSRect)rectForPage:(NSInteger)page;
@end

@interface MainCanvasView (UserInteraction)
- (void)mouseDown:(NSEvent*)event;
- (void)mouseUp:(NSEvent*)event;
- (void)mouseDragged:(NSEvent*)event;
- (NSMenu *)menuForEvent:(NSEvent *)event;
- (void)openInspectorWindow:(NSEvent *)theEvent;
@end

@interface MainCanvasView (Sorting)
- (void)moveCanvasObjects:(NSArray *)mcoList aboveOf:(CanvasObject *)coBelow;
- (BOOL)bringCanvasObjectToFront:(CanvasObject *)aCanvasObject;
- (BOOL)bringCanvasObjectToBack:(CanvasObject *)aCanvasObject;
@end

@interface MainCanvasView (FWKFile)
- (void)writeCanvasToURL:(NSURL *)url atomically:(BOOL)isAtomically;
- (NSString *)convertCanvasObjectsToString:(NSArray *)canvasObjects;
- (void)appendCanvasObjectsFromString:(NSString *)stringRep;
- (void)loadCanvasFromURL:(NSURL *)url;
@end


