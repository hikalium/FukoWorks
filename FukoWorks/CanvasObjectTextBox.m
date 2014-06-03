//
//  CanvasObjectTextBox.m
//  FukoWorks
//
//  Created by 西田　耀 on 2014/02/02.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectTextBox.h"
#import "NSColor+StringConversion.h"

//
// FWKCanvasTextField
//

@interface FWKCanvasTextField : NSTextField
@property (nonatomic) NSUndoManager *canvasUndoManager;
- (id)initWithDelegete: (id<NSTextFieldDelegate>)delegete;
- (NSAttributedString *)attributedString;
@end

@implementation FWKCanvasTextField

@synthesize canvasUndoManager = _canvasUndoManager;

- (id)initWithDelegete: (id<NSTextFieldDelegate>)delegete
{
    self = [super initWithFrame:NSMakeRect(0, 0, 10, 10)];
    if(self){
        [self setEditable:NO];
        [self setBezeled:NO];
        [self setBordered:NO];
        [self setAllowsEditingTextAttributes:YES];
        [self setDelegate:delegete];
        [self setStringValue:@"テキストを入力"];
        [self setFocusRingType:NSFocusRingTypeNone];
        [self setFont:[NSFont fontWithName:@"HiraMaruPro-W4" size:32]];
    }
    return self;
}

- (BOOL)acceptsFirstResponder
{
    return self.isEditable;
}

- (BOOL)resignFirstResponder
{
    [self setEditable:NO];
    return [super resignFirstResponder];
}

-(NSAttributedString *)attributedString
{
    return [self.cell attributedStringValue];
}

- (void)setAttributedStringValue:(NSAttributedString *)obj
{
    [[self.canvasUndoManager prepareWithInvocationTarget:self] setAttributedStringValue:self.attributedStringValue];
    [super setAttributedStringValue:obj];
    [self sizeToFit];
    [self.superview setFrameSize:NSZeroSize];    // 引数はダミー
}

@end

//
// CanvasObjectTextBox
//

@implementation CanvasObjectTextBox
{
    FWKCanvasTextField *textField;
}

- (void)setFillColor:(NSColor *)FillColor
{
    if(!textField.isEditable){
        [super setFillColor:FillColor];
    }
}

- (void)setStrokeColor:(NSColor *)StrokeColor
{
    if(!textField.isEditable){
        [super setStrokeColor:StrokeColor];
    }
}

- (void)setStrokeWidth:(CGFloat)StrokeWidth
{
    
    [super setStrokeWidth:StrokeWidth];
    [textField setFrameOrigin:self.bodyRectBounds.origin];
}
@synthesize ObjectType = _ObjectType;

- (void)setCanvasUndoManager:(NSUndoManager *)canvasUndoManager
{
    [super setCanvasUndoManager:canvasUndoManager];
    textField.canvasUndoManager = canvasUndoManager;
}

- (void)setRotationAngle:(CGFloat)rotationAngle
{
    [super setRotationAngle:rotationAngle];
    //
    NSPoint p;
    CGFloat theta = self.rotationAngle, fw, fh;
    //[textField setBoundsRotation:rotationAngle / pi * 180];
    [textField setFrameRotation:rotationAngle / pi * 180];
    fw = self.frame.size.width;
    fh = self.frame.size.height;
    p = NSMakePoint(0, 0);
    //
    if(theta < pi / 2){
        p.y = 0;
        p.x = sinf(theta) * textField.frame.size.height;
    } else if(theta < pi){
        p.y = -cosf(theta) * textField.frame.size.height;
        p.x = fw;
    } else if(theta < pi / 2 * 3){
        p.y = fh;
        p.x = -cosf(theta) * textField.frame.size.width;
    } else{
        p.y = -sin(theta) * textField.frame.size.width;
        p.x = 0;

    }
    [textField setFrameOrigin:p];
}

//
// NSView
//
- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _ObjectType = TextBox;
        textField = [[FWKCanvasTextField alloc] initWithDelegete:self];
        textField.drawsBackground = YES;
        textField.backgroundColor = [NSColor clearColor];
        [self addSubview:textField];
        [self controlTextDidEndEditing:nil];
        [self setStrokeWidth:self.StrokeWidth];
    }
    return self;
}

- (void)setFrameSize:(NSSize)newSize
{
    //サイズは自動設定なので、与えられた数値に関係なく設定する
    newSize = textField.frame.size;
    newSize.width += self.StrokeWidth;
    newSize.height += self.StrokeWidth;
    
    [super setFrameSize:newSize];
}

//
//CanvasObject
//
- (id)initWithEncodedString:(NSString *)sourceString
{
    NSArray *dataValues;
    NSUInteger index;
    NSData *atrstrdata;
    NSAttributedString *atrstr;
    NSString *s;
    CGFloat tmpAngle;
    
    dataValues = [sourceString componentsSeparatedByString:@"|"];
    
    self = [self initWithFrame:NSZeroRect];
    
    if(self){
        // BodyRect
        // RotationAngle
        // FillColor
        // StrokeColor
        // StrokeWidth
        // RTFData
        index = 0;
        s = [dataValues objectAtIndex:0];   index += s.length + 1;
        [self setBodyRect:NSRectFromString(s)];
        s = [dataValues objectAtIndex:1];   index += s.length + 1;
        tmpAngle = s.floatValue;
        s = [dataValues objectAtIndex:2];   index += s.length + 1;
        self.FillColor = [NSColor colorFromString:s forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        s = [dataValues objectAtIndex:3];   index += s.length + 1;
        self.StrokeColor = [NSColor colorFromString:s forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        s = [dataValues objectAtIndex:4];   index += s.length + 1;
        self.StrokeWidth = s.floatValue;
        atrstrdata = [[sourceString substringFromIndex:index] dataUsingEncoding:NSUTF8StringEncoding];
        atrstr = [[NSAttributedString alloc] initWithData:atrstrdata options:nil documentAttributes:nil error:nil];
        [textField setAttributedStringValue:atrstr];
        [self controlTextDidEndEditing:nil];
        self.rotationAngle = tmpAngle;
    }
    return self;
}

- (NSString *)encodedStringForCanvasObject
{
    NSMutableString *encodedString;
    NSAttributedString *atrstr;
    NSData *atrstrdata;
    
    encodedString = [[NSMutableString alloc] init];
    
    // BodyRect
    // RotationAngle
    // FillColor
    // StrokeColor
    // StrokeWidth
    // RTFData
    [encodedString appendFormat:@"%@|", NSStringFromRect(self.bodyRect)];
    [encodedString appendFormat:@"%f|", self.rotationAngle];
    [encodedString appendFormat:@"%@|", [self.FillColor stringRepresentation]];
    [encodedString appendFormat:@"%@|", [self.StrokeColor stringRepresentation]];
    [encodedString appendFormat:@"%f|", self.StrokeWidth];
    atrstr = [textField attributedString];
    atrstrdata = [atrstr RTFFromRange:NSMakeRange(0, atrstr.length) documentAttributes:nil];
    [encodedString appendFormat:@"%@", [[[NSString alloc] initWithData:atrstrdata encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
    return [NSString stringWithString:encodedString];
}

-(CanvasObject *)drawMouseDown:(NSPoint)currentPointInCanvas
{
    // 初期描画中は変形を記録しないようにする
    [[self.canvasUndoManager prepareWithInvocationTarget:self] setFrame:self.frame];
    //https://github.com/Pixen/Pixen/issues/228
    [self.canvasUndoManager endUndoGrouping];
    [self.canvasUndoManager disableUndoRegistration];
    //
    [super setFrameOrigin:currentPointInCanvas];
    return self;
}

- (CanvasObject *)drawMouseDragged:(NSPoint)currentPointInCanvas
{
    [super setFrameOrigin:currentPointInCanvas];

    return self;
}

- (CanvasObject *)drawMouseUp:(NSPoint)currentPointInCanvas
{
    [super setFrameOrigin:currentPointInCanvas];
    
    //
    [self.canvasUndoManager enableUndoRegistration];
    //
    return nil;
}

- (void)doubleClicked
{
    [self setRotationAngle:0];
    [[NSColorPanel sharedColorPanel] close];
    [[NSFontPanel sharedFontPanel] orderFront:self];
    [[NSColorPanel sharedColorPanel] orderFront:self];
    [textField setEditable:YES];
    [self focusInputField];
    [textField setTarget:self];
}

- (void)selected
{

}

- (void)deselected
{
    [textField setEditable:NO];
}

- (void)focusInputField {
    [textField selectText:self];
    [[textField currentEditor] setSelectedRange:NSMakeRange([[textField stringValue] length], 0)];
}

- (void)controlTextDidBeginEditing:(NSNotification *)obj
{
    [[self.canvasUndoManager prepareWithInvocationTarget:textField] setAttributedStringValue:[textField attributedString]];
    //
    [textField sizeToFit];
    [textField setFrameSize:NSMakeSize(textField.frame.size.width * 1.5 + 100, textField.frame.size.height)];
    [super setFrameSizeInternal:textField.frame.size];
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    [textField sizeToFit];
    [textField setFrameSize:NSMakeSize(textField.frame.size.width * 1.5 + 200, textField.frame.size.height)];
    [super setFrameSizeInternal:textField.frame.size];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    [textField sizeToFit];
    [super setFrameSizeInternal:textField.frame.size];
}

@end
