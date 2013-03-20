//
//  MainCanvasView.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CanvasObjectRectangle.h"

@interface MainCanvasView : NSView

@property (assign) IBOutlet NSWindow *parentwindow;
@property (strong, nonatomic) IBOutlet NSTextField *label_indicator;

- (id)initWithFrame:(NSRect)frame;
- (void)drawRect:(NSRect)dirtyRect;

- (void)mouseDown:(NSEvent*)event;
- (void)mouseUp:(NSEvent*)event;
- (void)mouseDragged:(NSEvent*)event;

- (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint;

@property CGColorRef drawingStrokeColor;
@property CGColorRef drawingFillColor;;
@property CGColorRef drawingTextColor;

@end
