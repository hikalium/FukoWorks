//
//  CanvasObject.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/28.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

//MainCanvasViewに描画されるすべてのオブジェクトのスーパークラス

#import <Cocoa/Cocoa.h>
#import "FukoWorks.h"

@interface CanvasObject : NSView
{
    NSView *editHandle[4];
    NSInteger editingHandleID;
}


@property (nonatomic) CGColorRef FillColor;
//
@property (nonatomic) CGColorRef StrokeColor;
@property (nonatomic) CGFloat StrokeWidth;
@property (readonly, nonatomic) CanvasObjectType ObjectType;
@property (nonatomic) BOOL Focused;
- (void)setFocused:(BOOL)Focused;

- (id)initWithFrame:(NSRect)frameRect;
- (void)drawRect:(NSRect)dirtyRect;


- (NSString *)encodedStringForObject;
- (NSString *)encodedStringForCGColorRef:(CGColorRef)cref;

- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas;
- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas;
- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas;
- (void)editHandleDown:(NSPoint)currentHandlePointInCanvas :(NSInteger) tag;
- (void)editHandleDragged:(NSPoint)currentHandlePointInCanvas :(NSInteger) tag;
- (void)editHandleUp:(NSPoint)currentHandlePointInCanvas :(NSInteger) tag;

//上記三関数は、次の描画指示をすべきオブジェクトを返す。
//つまり、描画処理が完了するとnilを返す。それまではオブジェクト自身を返す。

- (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint;
- (NSRect)makeNSRectWithRealSizeViewFrame;
- (NSRect)makeNSRectWithRealSizeViewFrameInLocal;
- (NSRect)makeNSRectWithFullSizeViewFrameFromRealSizeViewFrame:(NSRect)RealSizeViewFrame;
- (NSPoint)getPointerLocationRelativeToSelfView:(NSEvent*)event;

@end
