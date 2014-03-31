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
- (id)initWithDelegete: (id<NSTextFieldDelegate>)delegete;
- (NSAttributedString *)attributedString;
@end

@implementation FWKCanvasTextField

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
    newSize = self.bodyRect.size;
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
    
    dataValues = [sourceString componentsSeparatedByString:@"|"];
    
    self = [self initWithFrame:NSZeroRect];
    
    if(self){
        // BodyRect|FillColor|StrokeColor|StrokeWidth|RTFData
        [self setBodyRect:NSRectFromString([dataValues objectAtIndex:0])];
        self.FillColor = [NSColor colorFromString:[dataValues objectAtIndex:1] forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        self.StrokeColor = [NSColor colorFromString:[dataValues objectAtIndex:2] forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        self.StrokeWidth = ((NSString *) [dataValues objectAtIndex:3]).floatValue;
        index = 0;
        index += [[dataValues objectAtIndex:0] length] + 1;
        index += [[dataValues objectAtIndex:1] length] + 1;
        index += [[dataValues objectAtIndex:2] length] + 1;
        index += [[dataValues objectAtIndex:3] length] + 1;
        atrstrdata = [[sourceString substringFromIndex:index] dataUsingEncoding:NSUTF8StringEncoding];
        atrstr = [[NSAttributedString alloc] initWithData:atrstrdata options:nil documentAttributes:nil error:nil];
        [textField setAttributedStringValue:atrstr];
        [self controlTextDidEndEditing:nil];
    }
    return self;
}
//Frame|FillColor|StrokeColor|StrokeWidth
- (NSString *)encodedStringForCanvasObject
{
    NSMutableString *encodedString;
    NSAttributedString *atrstr;
    NSData *atrstrdata;
    
    encodedString = [[NSMutableString alloc] init];
    
    // BodyRect|FillColor|StrokeColor|StrokeWidth|RTFData
    [encodedString appendFormat:@"%@|", NSStringFromRect(self.bodyRect)];
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
    return nil;
}

- (void)doubleClicked
{
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
    [textField sizeToFit];
    [textField setFrameSize:NSMakeSize(textField.frame.size.width * 1.5 + 100, textField.frame.size.height)];
    [super setFrameSize:textField.frame.size];
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    [textField sizeToFit];
    [textField setFrameSize:NSMakeSize(textField.frame.size.width * 1.5 + 200, textField.frame.size.height)];
    [super setFrameSize:textField.frame.size];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    [textField sizeToFit];
    [super setFrameSize:textField.frame.size];
    //[[NSFontPanel sharedFontPanel] close];
}

@end
