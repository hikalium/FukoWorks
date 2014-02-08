//
//  CanvasObjectTextBox.m
//  FukoWorks
//
//  Created by 西田　耀 on 2014/02/02.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectTextBox.h"

@interface FWKCanvasTextField : NSTextField

@end

@implementation FWKCanvasTextField

- (id)initWithDelegete: (id<NSTextFieldDelegate>)delegete
{
    self = [super initWithFrame:NSMakeRect(0, 0, 10, 10)];
    if(self){
        //[self setEnabled:NO];
        [self setEditable:NO];
        [self setBezeled:NO];
        [self setBordered:NO];
        [self setDrawsBackground:NO];
        [self setAllowsEditingTextAttributes:YES];
        [self setDelegate:delegete];
        [self setStringValue:@"テキストを入力"];
        [self setFocusRingType:NSFocusRingTypeNone];
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
@end

@implementation CanvasObjectTextBox
{
    FWKCanvasTextField *textField;
}

@synthesize ObjectType = _ObjectType;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _ObjectType = TextBox;
        textField = [[FWKCanvasTextField alloc] initWithDelegete:self];
        [self addSubview:textField];
        [self controlTextDidChange:nil];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
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
    [textField setEditable:YES];
}

- (void)deselected
{
    NSLog(@"adasg");
    [textField setEditable:NO];
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
    [textField setFrameSize:NSMakeSize(textField.frame.size.width * 1.5 + 100, textField.frame.size.height)];
    [super setFrameSize:textField.frame.size];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    [textField sizeToFit];
    [super setFrameSize:textField.frame.size];
}

@end
