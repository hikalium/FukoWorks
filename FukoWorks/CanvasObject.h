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


@property (nonatomic) NSColor *FillColor;
@property (nonatomic) NSColor *StrokeColor;
@property (nonatomic) CGFloat StrokeWidth;
@property (readonly, nonatomic) CanvasObjectType ObjectType;
@property (readonly, nonatomic) NSString *ObjectTypeName;
@property (nonatomic) NSString *objectName;
@property (nonatomic) BOOL Focused;
@property (nonatomic) NSUndoManager *undoManager;

- (void)setFocused:(BOOL)Focused;

- (id)initWithFrame:(NSRect)frameRect;
- (id)initWithEncodedString:(NSString *)sourceString;
- (void)drawRect:(NSRect)dirtyRect;


- (NSString *)encodedStringForCanvasObject;
+ (NSString *)encodedStringForCGColorRef:(CGColorRef)cref;
+ (CGColorRef)decodedCGColorRefFromString:(NSString *)sourceString;

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
