//
//  MainCanvasView.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ToolBoxController.h"

@interface MainCanvasView : NSView
{
    NSPoint drawingStartPoint;
    CGColorRef backgroundColor;
    NSRect baseFrame;
}

@property (strong, nonatomic) NSTextField *label_indicator;

- (id)initWithFrame:(NSRect)frame;
- (void)drawRect:(NSRect)dirtyRect;

- (void)mouseDown:(NSEvent*)event;
- (void)mouseUp:(NSEvent*)event;
- (void)mouseDragged:(NSEvent*)event;

- (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint;
- (NSPoint)getPointerLocationRelativeToSelfView:(NSEvent*)event;

@property (nonatomic) ToolBoxController *toolboxController;
@property (nonatomic) CGFloat canvasScale;

@end
