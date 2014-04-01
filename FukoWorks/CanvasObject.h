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
#import "CanvasObjectHandling.h"

@interface CanvasObject : NSView<CanvasObjectHandling>
{
    
}

//
// Property
//

// baseColor
@property (nonatomic) NSColor *FillColor;
@property (nonatomic) NSColor *StrokeColor;

// objectShape
@property (nonatomic) CGFloat StrokeWidth;
@property (nonatomic) NSRect bodyRect;
@property (nonatomic, readonly) NSRect bodyRectBounds;

// objectInfo
@property (readonly, nonatomic) CanvasObjectType ObjectType;
@property (readonly, nonatomic) NSString *ObjectTypeName;
@property (nonatomic) NSString *objectName;
@property (nonatomic, readonly) NSString *uuid;
@property (nonatomic, readonly) BOOL isSelected;

// MainCanvasView property
@property (nonatomic) NSUndoManager *canvasUndoManager;   //MainCanvasViewが設定する。
@property (nonatomic) NSArray *editHandleList;  //MainCanvasViewが設定する。
@property (nonatomic) NSView *ownerMainCanvasView;  //MainCanvasViewが設定する。

//
// Function
//

// NSView override
- (id)initWithFrame:(NSRect)frameRect;
- (void)drawRect:(NSRect)dirtyRect;
- (void)setFrame:(NSRect)frameRect;

//
- (void)drawFocusRect;

// data encoding
- (id)initWithEncodedString:(NSString *)sourceString;
- (NSString *)encodedStringForCanvasObject;
//+ (NSString *)encodedStringForCGColorRef:(CGColorRef)cref;
//+ (CGColorRef)decodedCGColorRefFromString:(NSString *)sourceString;

// Preview drawing
- (CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas;
- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas;
- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas;
//上記関数は、次の描画指示をすべきオブジェクトを返す。
//つまり、描画処理が完了するとnilを返す。それまではオブジェクト自身を返す。

// User interaction
- (void)doubleClicked;
- (void)selected;
- (void)deselected;
- (void)moved;

// EditHandle <CanvasObjectHandling>
- (NSUInteger)numberOfEditHandlesForCanvasObject;

// ViewComputing
+ (NSRect)makeNSRectFromMouseMoving:(NSPoint)startPoint :(NSPoint)endPoint;
- (NSPoint)getPointerLocationRelativeToSelfView:(NSEvent*)event;

@end
