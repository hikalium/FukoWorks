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

@interface MainCanvasView : NSView
{
    NSPoint drawingStartPoint;
    NSPoint drawingDragPoint;
    bool clickOnly;
    
    CGColorRef backgroundColor;
    
    CanvasObject *editingObject;
    
    CanvasObject *movingObject;
    NSPoint moveHandleOffset;
    
    NSRect baseFrame;
    
    NSMutableArray *inspectorWindows;
}

@property (strong, nonatomic) NSTextField *label_indicator;
@property (nonatomic) ToolboxController *toolboxController;
@property (nonatomic) CGFloat canvasScale;
@property (nonatomic) CanvasObject *focusedObject;
@property (nonatomic) NSSize canvasSize;

- (id)initWithFrame:(NSRect)frame;
- (void)drawRect:(NSRect)dirtyRect;

- (void)mouseDown:(NSEvent*)event;
- (void)mouseUp:(NSEvent*)event;
- (void)mouseDragged:(NSEvent*)event;
- (void)rightMouseUp:(NSEvent *)theEvent;

- (void)resetCursorRects;

- (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint;
- (NSPoint)getPointerLocationRelativeToSelfView:(NSEvent*)event;
- (CanvasObject *)getCanvasObjectAtCursorLocation:(NSEvent *)event;

- (void)writeCanvasToURL:(NSURL *)url atomically:(BOOL)isAtomically;
- (void)loadCanvasFromURL:(NSURL *)url;

@end
