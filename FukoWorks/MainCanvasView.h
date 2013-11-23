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
#import "OverlayCanvasView.h"

@interface MainCanvasView : NSView
{
    NSUndoManager *undoManager;
    NSPoint drawingStartPoint;
    NSPoint drawingDragPoint;
    
    CGColorRef backgroundColor;
    
    CanvasObject *editingObject;
    
    CanvasObject *movingObject;
    NSPoint moveHandleOffset;
    
    CanvasObjectPaintFrame *drawingPaintFrame;
    
    NSRect baseFrame;
    
    NSMutableArray *inspectorWindows;
    OverlayCanvasView *overlayView;
}

@property (strong, nonatomic) NSTextField *label_indicator;
@property (nonatomic) ToolboxController *toolboxController;
@property (nonatomic) CGFloat canvasScale;
@property (nonatomic) CanvasObject *focusedObject;
@property (nonatomic) NSSize canvasSize;
@property (nonatomic, readonly) NSMutableArray *canvasObjects;

- (id)initWithFrame:(NSRect)frame;
- (void)drawRect:(NSRect)dirtyRect;

- (void)mouseDown:(NSEvent*)event;
- (void)mouseUp:(NSEvent*)event;
- (void)mouseDragged:(NSEvent*)event;

- (void)rightMouseUp:(NSEvent *)theEvent;

- (void)resetCursorRects;

- (void)appendCanvasObject:(CanvasObject *)aCanvasObject;
- (void)removeCanvasObject:(CanvasObject *)aCanvasObject;

- (void)moveCanvasObjects:(NSArray *)mcoList aboveOf:(CanvasObject *)coBelow;

- (BOOL)bringCanvasObjectToFront:(CanvasObject *)aCanvasObject;
- (BOOL)bringCanvasObjectToBack:(CanvasObject *)aCanvasObject;


- (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint;
- (NSPoint)getPointerLocationRelativeToSelfView:(NSEvent*)event;
- (NSPoint)getPointerLocationInScreen:(NSEvent *)event;
- (CanvasObject *)getCanvasObjectAtCursorLocation:(NSEvent *)event;

- (void)writeCanvasToURL:(NSURL *)url atomically:(BOOL)isAtomically;
- (NSString *)convertCanvasObjectsToString:(NSArray *)canvasObjects;
- (void)appendCanvasObjectsFromString:(NSString *)stringRep;
- (void)loadCanvasFromURL:(NSURL *)url;

- (IBAction)copy:(id)sender;
- (IBAction)paste:(id)sender;
- (IBAction)cut:(id)sender;
- (IBAction)delete:(id)sender;

- (IBAction)undo:(id)sender;
- (IBAction)redo:(id)sender;

@end
