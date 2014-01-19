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
    
    if(editingObject == nil){
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
                editingObject = [[CanvasObjectRectangle alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
            case Ellipse:
                editingObject = [[CanvasObjectEllipse alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
            case PaintFrame:
                editingObject = [[CanvasObjectPaintFrame alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
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
        if(editingObject != nil){
            editingObject.FillColor = self.toolboxController.drawingFillColor;
            editingObject.StrokeColor = self.toolboxController.drawingStrokeColor;
            editingObject.StrokeWidth = self.toolboxController.drawingStrokeWidth;
            editingObject.undoManager = undoManager;
            [self addCanvasObject:editingObject];
            
            editingObject = [editingObject drawMouseDown:currentPoint];
        }
    } else{
        //図形描画の途中
        editingObject = [editingObject drawMouseDown:currentPoint];
    }
    //ペイント枠に描くなら描く
    if(drawingPaintFrame){
        drawingPaintFrame.FillColor = self.toolboxController.drawingFillColor;
        drawingPaintFrame.StrokeColor = self.toolboxController.drawingStrokeColor;
        drawingPaintFrame.StrokeWidth = self.toolboxController.drawingStrokeWidth;
        [drawingPaintFrame drawPaintFrameMouseDown:currentPoint mode:self.toolboxController.drawingObjectType];
    }
}

- (void)mouseDragged:(NSEvent*)event
{
    NSPoint currentPoint;
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDr:%@", NSStringFromPoint(currentPoint)]];
    
    //作成中の図形があるなら座標を送る
    editingObject = [editingObject drawMouseDragged:currentPoint];
    
    //図形移動するならする
    [movingObject setFrameOrigin:NSMakePoint(currentPoint.x - moveHandleOffset.x, currentPoint.y - moveHandleOffset.y)];
    
    //ペイント枠に描くなら描く
    [drawingPaintFrame drawPaintFrameMouseDragged:currentPoint mode:self.toolboxController.drawingObjectType];
}

- (void)mouseUp:(NSEvent*)event
{
    NSPoint currentPoint;
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mUp:%@", NSStringFromPoint(currentPoint)]];
    
    editingObject = [editingObject drawMouseUp:currentPoint];
    
    //フォーカスを戻す
    [self resetCanvasObjectHandleForCanvasObject:movingObject];
    [self showCanvasObjectHandleForCanvasObject:movingObject];
    
    //図形移動終了
    movingObject = nil;
    
    
    //ペイント枠に描くなら描く
    [drawingPaintFrame drawPaintFrameMouseUp:currentPoint mode:self.toolboxController.drawingObjectType];
    
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
    
    if(editingObject == nil){
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
