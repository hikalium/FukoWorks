//
//  InspectorWindowController.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/06/09.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "InspectorWindowController.h"
#import "NSString+PixelConversion.h"
#import "MainCanvasView.h"

@implementation InspectorWindowController

- (id)init
{
    self = [super initWithWindowNibName:[self className]];
    
    if(self){
        editingCanvasObject = nil;
        editingView = nil;
    }
    
    return self;
}

- (id)initWithEditView:(NSView *)editView
{
    self = [self init];
    
    if(self){
        editingView = editView;
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    if([editingView isKindOfClass:[CanvasObject class]]){
        //オブジェクト設定
        editingCanvasObject = (CanvasObject *)editingView;
        editTypeLabel.stringValue = editingCanvasObject.ObjectTypeName;
        [tboxSizeX setEnabled:YES];
        [tboxSizeY setEnabled:YES];
        tboxSizeX.floatValue = editingCanvasObject.frame.size.width;
        tboxSizeY.floatValue = editingCanvasObject.frame.size.height;
    } else if([editingView isKindOfClass:[MainCanvasView class]]){
        //キャンバス設定
        editTypeLabel.stringValue = @"キャンバス";
        [tboxSizeX setEnabled:YES];
        [tboxSizeY setEnabled:YES];
        tboxSizeX.floatValue = ((MainCanvasView *)editingView).canvasSize.width;
        tboxSizeY.floatValue = ((MainCanvasView *)editingView).canvasSize.height;
    }
}

- (IBAction)changeTextFieldValue:(id)sender
{
    NSTextField *anTextField;
    CGFloat tempValue;
    
    if([sender isKindOfClass:[NSTextField class]]){
        anTextField = (NSTextField *)sender;
        
        switch (anTextField.tag) {
            case 1:
                //SizeX
                tempValue = [anTextField.stringValue convertPixelUnitWithDefaultValue:0];
                if(tempValue > 0){
                    if([editingView isKindOfClass:[MainCanvasView class]]){
                        //キャンバス設定
                        [((MainCanvasView *)editingView) setCanvasSize:NSMakeSize(tempValue, ((MainCanvasView *)editingView).canvasSize.height)];
                    } else{
                        [editingView setFrameSize:NSMakeSize(tempValue, editingView.frame.size.height)];
                    }
                }
                break;
            case 2:
                //SizeY
                tempValue = [anTextField.stringValue convertPixelUnitWithDefaultValue:0];
                if(tempValue > 0){
                    if([editingView isKindOfClass:[MainCanvasView class]]){
                        //キャンバス設定
                        [((MainCanvasView *)editingView) setCanvasSize:NSMakeSize(((MainCanvasView *)editingView).canvasSize.width, tempValue)];
                    } else{
                        [editingView setFrameSize:NSMakeSize(editingView.frame.size.width, tempValue)];
                    }
                }
                break;
            case 3:
                //LocationX
                //tempValue = anTextField.floatValue;
                
                break;
            case 4:
                //LocationY
                tempValue = anTextField.floatValue;
                if(tempValue > 0){
                   // draw
                }
                
                break;
        }
    }
}

@end
