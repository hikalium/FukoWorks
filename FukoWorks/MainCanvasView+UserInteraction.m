//
//  MainCanvasView+UserInteraction.m
//  FukoWorks
//
//  Created by 西田　耀 on 2014/01/19.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "MainCanvasView.h"

@implementation MainCanvasView (UserInteraction)
//
// User interaction
//

- (void)mouseDown:(NSEvent*)event
{
    NSPoint currentPoint;
    
    //key取得のためにFirstResponderに設定
    [self.superview.window makeFirstResponder:self];
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDw:%@", NSStringFromPoint(currentPoint)]];
    
    if(creatingObject == nil){
        //作成中の図形はない
        //図形の新規作成or移動
        switch(self.toolboxController.drawingObjectType){
            case Undefined:
                //カーソルモード
                //図形移動を初期化
                movingObject = [self getCanvasObjectAtCursorLocation:event];
                if(movingObject){
                    moveHandleOffset = NSMakePoint(currentPoint.x - movingObject.frame.origin.x, currentPoint.y - movingObject.frame.origin.y);
                }
                //移動中はフォーカスを消す
                [self hideCanvasObjectHandleForCanvasObject:movingObject];
                break;
            case Rectangle:
                creatingObject = [[CanvasObjectRectangle alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
            case Ellipse:
                creatingObject = [[CanvasObjectEllipse alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
            case PaintFrame:
                creatingObject = [[CanvasObjectPaintFrame alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
            case PaintRectangle:
            case PaintEllipse:
            case PaintPen:
                NSLog(@"Draw in paint frame.\n");
                break;
            default:
                NSLog(@"Not implemented operation to make a new object.\n");
                break;
        }
        if(creatingObject != nil){
            creatingObject.FillColor = self.toolboxController.drawingFillColor;
            creatingObject.StrokeColor = self.toolboxController.drawingStrokeColor;
            creatingObject.StrokeWidth = self.toolboxController.drawingStrokeWidth;
            creatingObject.undoManager = undoManager;
            [self addCanvasObject:creatingObject];
            
            creatingObject = [creatingObject drawMouseDown:currentPoint];
        }
    } else{
        //図形作成の途中
        creatingObject = [creatingObject drawMouseDown:currentPoint];
    }
    //ペイント枠に描くなら描く
    if(editingPaintFrame){
        editingPaintFrame.FillColor = self.toolboxController.drawingFillColor;
        editingPaintFrame.StrokeColor = self.toolboxController.drawingStrokeColor;
        editingPaintFrame.StrokeWidth = self.toolboxController.drawingStrokeWidth;
        [editingPaintFrame drawPaintFrameMouseDown:currentPoint mode:self.toolboxController.drawingObjectType];
    }
}

- (void)mouseDragged:(NSEvent*)event
{
    NSPoint currentPoint;
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDr:%@", NSStringFromPoint(currentPoint)]];
    
    //作成中の図形があるなら座標を送る
    creatingObject = [creatingObject drawMouseDragged:currentPoint];
    
    //図形移動するならする
    [movingObject setFrameOrigin:NSMakePoint(currentPoint.x - moveHandleOffset.x, currentPoint.y - moveHandleOffset.y)];
    
    //ペイント枠に描くなら描く
    [editingPaintFrame drawPaintFrameMouseDragged:currentPoint mode:self.toolboxController.drawingObjectType];
}

- (void)mouseUp:(NSEvent*)event
{
    NSPoint currentPoint;
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mUp:%@", NSStringFromPoint(currentPoint)]];
    
    creatingObject = [creatingObject drawMouseUp:currentPoint];
    
    //フォーカスを戻す
    [self resetCanvasObjectHandleForCanvasObject:movingObject];
    [self showCanvasObjectHandleForCanvasObject:movingObject];
    
    //図形移動終了
    movingObject = nil;
    
    
    //ペイント枠に描くなら描く
    [editingPaintFrame drawPaintFrameMouseUp:currentPoint mode:self.toolboxController.drawingObjectType];
    
    if([event clickCount] == 1){
        //クリック。
        //フォーカスを与える。
        [self selectCanvasObject:[self getCanvasObjectAtCursorLocation:event]];
    }
    
    
}

- (void)rightMouseDown:(NSEvent *)theEvent
{
    NSPoint currentPointInScreen;
    currentPointInScreen = [self getPointerLocationInScreen:theEvent];
    
    //編集終了or詳細設定
    CanvasObject *aCanvasObject;
    InspectorWindowController *anInspectorWindowController;
    
    if(creatingObject == nil){
        //詳細設定を開く
        aCanvasObject = [self getCanvasObjectAtCursorLocation:theEvent];
        if(aCanvasObject == nil){
            //キャンバスの詳細設定
            anInspectorWindowController = [[InspectorWindowController alloc] initWithEditView:self];
        } else{
            //オブジェクトの詳細設定
            anInspectorWindowController = [[InspectorWindowController alloc] initWithEditView:aCanvasObject];
        }
        [inspectorWindows addObject:anInspectorWindowController];
        [anInspectorWindowController showWindow:self];
        [[anInspectorWindowController window]setFrameOrigin:currentPointInScreen];
    }
}

- (void)rightMouseUp:(NSEvent *)theEvent
{
    //self.focusedObject = [self getCanvasObjectAtCursorLocation:theEvent];
}



/*
 - (void)keyDown:(NSEvent *)theEvent
 {
 NSInteger keyCode;
 
 keyCode = [theEvent keyCode];
 NSLog(@"%ld", keyCode);
 
 switch(keyCode){
 case 51:
 //Backspace
 case 117:
 //Delete(Backspace+Fn)
 [self removeCanvasObject:_focusedObject];
 break;
 }
 
 }
 */
@end
