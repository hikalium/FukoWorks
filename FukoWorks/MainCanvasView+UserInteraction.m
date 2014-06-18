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
                    // 一回の移動で一回だけ実行するようにするためのフラグ
                    needsMoveUndoRegistration = YES;
                    //
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
            case TextBox:
                creatingObject = [[CanvasObjectTextBox alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
            case Line:
                creatingObject = [[CanvasObjectLine alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
            case BezierPath:
                creatingObject = [[CanvasObjectBezierPath alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];
                break;
            //
            case PaintRectangle:
            case PaintEllipse:
            case PaintPen:
                //NSLog(@"Draw in paint frame.\n");
                break;
            default:
                //NSLog(@"Not implemented operation to make a new object.\n");
                break;
        }
        if(creatingObject != nil){
            // undoのグループ化を開始
            [canvasUndoManager beginUndoGrouping];
            creatingObject.FillColor = self.toolboxController.drawingFillColor;
            creatingObject.StrokeColor = self.toolboxController.drawingStrokeColor;
            creatingObject.StrokeWidth = self.toolboxController.drawingStrokeWidth;
            creatingObject.canvasUndoManager = canvasUndoManager;
            [self addCanvasObject:creatingObject];
        }
    }
    
    if(creatingObject){
        //作成中の図形があるので座標を送る
        creatingObject = [creatingObject drawMouseDown:currentPoint];
        if(!creatingObject){
            [self endObjectCreation];
        }
    }
    
    //ペイント枠に描くなら描く
    if(editingPaintFrame){
        editingPaintFrame.PaintFillColor = self.toolboxController.drawingFillColor;
        editingPaintFrame.PaintStrokeColor = self.toolboxController.drawingStrokeColor;
        editingPaintFrame.PaintStrokeWidth = self.toolboxController.drawingStrokeWidth;
        [editingPaintFrame drawPaintFrameMouseDown:currentPoint mode:self.toolboxController.drawingObjectType];
    }
}

- (void)mouseDragged:(NSEvent*)event
{
    NSPoint currentPoint;
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mDr:%@", NSStringFromPoint(currentPoint)]];
    
    if(creatingObject){
        //作成中の図形があるので座標を送る
        creatingObject = [creatingObject drawMouseDragged:currentPoint];
        if(!creatingObject){
            [self endObjectCreation];
        }
    }
    
    //図形移動するならする
    if(movingObject && needsMoveUndoRegistration){
        // 一回の移動で一回だけ実行するようにするためのフラグ
        needsMoveUndoRegistration = NO;
        // 動かす前の位置を記憶しておく
        [canvasUndoManager beginUndoGrouping];
        [[canvasUndoManager prepareWithInvocationTarget:movingObject] setFrameOrigin:movingObject.frame.origin];
    }
    [movingObject setFrameOrigin:NSMakePoint(currentPoint.x - moveHandleOffset.x, currentPoint.y - moveHandleOffset.y)];
    
    //ペイント枠に描くなら描く
    [editingPaintFrame drawPaintFrameMouseDragged:currentPoint mode:self.toolboxController.drawingObjectType];
}

- (void)mouseUp:(NSEvent*)event
{
    NSPoint currentPoint;
    
    currentPoint = [self getPointerLocationRelativeToSelfView:event];
    [self.label_indicator setStringValue:[NSString stringWithFormat:@"mUp:%@", NSStringFromPoint(currentPoint)]];
    
    if(creatingObject){
        //作成中の図形があるので座標を送る
        creatingObject = [creatingObject drawMouseUp:currentPoint];
        if(!creatingObject){
            [self endObjectCreation];
        }
    }
    
    //図形移動終了を報告（移動していない場合は送信しない）
    if(!needsMoveUndoRegistration){
        [movingObject moved];
    }
    
    //フォーカスを戻す
    [self resetCanvasObjectHandleForCanvasObject:movingObject];
    [self showCanvasObjectHandleForCanvasObject:movingObject];

    //移動したのでUndoのグループ化を終了
    if(movingObject && !needsMoveUndoRegistration){
        [canvasUndoManager endUndoGrouping];
    }
    movingObject = nil;
    
    //ペイント枠に描くなら描く
    [editingPaintFrame drawPaintFrameMouseUp:currentPoint mode:self.toolboxController.drawingObjectType];
    
    if([event clickCount] == 1){
        //クリック。
        //フォーカスを与える。
        [self selectCanvasObject:[self getCanvasObjectAtCursorLocation:event]];
    } else if([event clickCount] == 2){
        //Double clicked.
        [[self getCanvasObjectAtCursorLocation:event] doubleClicked];
    }
    
    
}

- (void)endObjectCreation
{
    //作成が終了したらundoのグループ化を終了
    [canvasUndoManager endUndoGrouping];
    [self.toolboxController endObjectCreation];
}

- (NSMenu *)menuForEvent:(NSEvent *)event
{
    // 右クリック時に呼ばれる
    // メニューを開く
    rightClickedObject = [self getCanvasObjectAtCursorLocation:event];
    rightClickedLocationInScreen = [self getPointerLocationInScreen:event];
    
    NSMenu *menu = [[NSMenu alloc] init];
    [menu insertItemWithTitle:@"詳細設定" action:@selector(openInspectorWindow:) keyEquivalent:@"" atIndex:0];
    
    return menu;
}

- (void)openInspectorWindow:(NSMenuItem *)theMenuItem
{
    
    InspectorWindowController *anInspectorWindowController;
    
    if(creatingObject == nil){
        //詳細設定を開く
        if(rightClickedObject == nil){
            //キャンバスの詳細設定
            anInspectorWindowController = [[InspectorWindowController alloc] initWithEditView:self];
        } else{
            //オブジェクトの詳細設定
            anInspectorWindowController = [[InspectorWindowController alloc] initWithEditView:rightClickedObject];
        }
        [inspectorWindows addObject:anInspectorWindowController];
        [anInspectorWindowController showWindow:self];
        [[anInspectorWindowController window]setFrameOrigin:rightClickedLocationInScreen];
    }
}
/*
- (void)rightMouseUp:(NSEvent *)theEvent
{
    //self.focusedObject = [self getCanvasObjectAtCursorLocation:theEvent];
}
*/


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
