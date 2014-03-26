//
//  CanvasObjectTextBox.m
//  FukoWorks
//
//  Created by 西田　耀 on 2014/02/02.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectTextBox.h"
#import "NSColor+StringConversion.h"

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
        [self setBackgroundColor:[NSColor whiteColor]];
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

@implementation CanvasObjectTextBox
{
    FWKCanvasTextField *textField;
}

@synthesize ObjectType = _ObjectType;
- (void)setStrokeColor:(NSColor *)StrokeColor
{
    return;
}
-(NSColor *)StrokeColor
{
    return nil;
}
-(void)setStrokeWidth:(CGFloat)StrokeWidth
{
    return;
}
- (CGFloat)StrokeWidth
{
    return 1;
}
-(void)setFillColor:(NSColor *)FillColor
{
    [textField setBackgroundColor:FillColor];
    return;
}
-(NSColor *)FillColor
{
    return textField.backgroundColor;
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
        [self addSubview:textField];
        [self controlTextDidEndEditing:nil];
        self.StrokeColor = textField.textColor;
        self.FillColor = textField.backgroundColor;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    [self drawFocusRect];
}

- (void)setFrame:(NSRect)frameRect
{
    //サイズは自動設定なので変更させない
    frameRect.size = self.frame.size;
    [super setFrame:frameRect];
}

- (void)setFrameSize:(NSSize)newSize
{
    //サイズは自動設定なので変更させない
    return;
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
    
    self = [self initWithFrame:NSRectFromString([dataValues objectAtIndex:0])];
    
    if(self){
        self.FillColor = [NSColor colorFromString:[dataValues objectAtIndex:1] forColorSpace:[NSColorSpace deviceRGBColorSpace]];
        index = 0;
        index += [[dataValues objectAtIndex:0] length] + 1;
        index += [[dataValues objectAtIndex:1] length] + 1;
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
    
    [encodedString appendFormat:@"%@|", NSStringFromRect(self.frame)];
    [encodedString appendFormat:@"%@|", [self.FillColor stringRepresentation]];
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
    [[NSFontPanel sharedFontPanel] orderFront:self];
    [[NSColorPanel sharedColorPanel] orderFront:self];
    [textField setEditable:YES];
    [self focusInputField];
    [textField setTarget:self];
}

- (void)selected
{
    //[[NSColorPanel sharedColorPanel] setColor:textField.textColor];
    [[NSColorPanel sharedColorPanel] setTarget:nil];
}

- (void)deselected
{
    NSLog(@"adasg");
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
    NSLog(@"called!");
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
