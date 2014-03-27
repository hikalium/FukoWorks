//
//  MainCanvasView+CanvasObjectSelection.m
//  FukoWorks
//
//  Created by 西田　耀 on 2014/01/19.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "MainCanvasView.h"

@implementation MainCanvasView (CanvasObjectSelection)
//
// select / deselect CanvasObject
//

- (void)selectCanvasObject:(CanvasObject *)aCanvasObject
{
    if(!([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask)){
        //Shiftキーを押していないので、現在の選択を、選択しようとしているものを除いて全て解除
        [self deselectAllCanvasObjectExceptFor:aCanvasObject];
    }
    if(!aCanvasObject || [objectHandles objectForKey:aCanvasObject.uuid]){
        //すでに選択されている
        if(([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask)){
            //Shiftキーが押されている場合は選択解除
            [self deselectCanvasObject:aCanvasObject];
        }
        return;
    }
    //OFF -> ON
    //NSUInteger handles = [aCanvasObject numberOfEditHandlesForCanvasObject];
    //if(handles != 0){
        //この空配列はダミー
        //実際はresetCanvasObjectHandleForCanvasObjectで設定される。
        [objectHandles setValue:[NSMutableArray array] forKey:aCanvasObject.uuid];
        [selectedObjects addObject:aCanvasObject];
        [self resetCanvasObjectHandleForCanvasObject:aCanvasObject];
        [self checkEditingObject];
    //}
    [aCanvasObject selected];
}

- (void)resetCanvasObjectHandleForCanvasObject:(CanvasObject *)aCanvasObject
{
    NSMutableArray *handleList;
    NSUInteger i;
    CanvasObjectHandle *anEditHandle;
    
    handleList = [objectHandles objectForKey:aCanvasObject.uuid];
    if(!handleList){
        //選択されていないのでなにもしない
        return;
    }
    NSUInteger handles = [aCanvasObject numberOfEditHandlesForCanvasObject];
    if(handles != handleList.count){
        //ハンドルの数が変化しているので、一度すべて削除してから追加しなおす
        for(i = 0; i < handleList.count; i++){
            [((NSView *)[handleList objectAtIndex:i])removeFromSuperview];
        }
        [objectHandles removeObjectForKey:aCanvasObject.uuid];
        //追加
        handleList = [[NSMutableArray alloc] init];
        for(i = 0; i < handles; i++){
            anEditHandle = [[CanvasObjectHandle alloc] init];
            [handleList addObject:anEditHandle];
            //ハンドルはMainCanvasと同じレイヤに置く。
            anEditHandle.ownerCanvasObject = aCanvasObject;
            anEditHandle.hid = i;
            [self.superview addSubview:anEditHandle];
        }
        [objectHandles setValue:handleList forKey:aCanvasObject.uuid];
        aCanvasObject.editHandleList = handleList;
    }
    //ハンドル位置の更新
    for(i = 0; i < handles; i++){
        anEditHandle = [handleList objectAtIndex:i];
        [anEditHandle setHandlePoint:[aCanvasObject editHandlePointForHandleID:i]];
    }
}

- (void)resetAllCanvasObjectHandle
{
    //適当
    NSUInteger i;
    
    for(i = 0; i < self.canvasObjects.count; i++){
        [self resetCanvasObjectHandleForCanvasObject:self.canvasObjects[i]];
    }
}

- (void)hideCanvasObjectHandleForCanvasObject:(CanvasObject *)aCanvasObject
{
    NSMutableArray *handleList;
    NSUInteger i;
    
    handleList = [objectHandles objectForKey:aCanvasObject.uuid];
    if(!handleList){
        //選択されていないのでなにもしない
        return;
    }
    for(i = 0; i < handleList.count; i++){
        [((NSView *)[handleList objectAtIndex:i]) setHidden:YES];
    }
}

- (void)showCanvasObjectHandleForCanvasObject:(CanvasObject *)aCanvasObject
{
    NSMutableArray *handleList;
    NSUInteger i;
    
    handleList = [objectHandles objectForKey:aCanvasObject.uuid];
    if(!handleList){
        //選択されていないのでなにもしない
        return;
    }
    for(i = 0; i < handleList.count; i++){
        [((NSView *)[handleList objectAtIndex:i]) setHidden:NO];
    }
}

- (void)deselectCanvasObject:(CanvasObject *)aCanvasObject
{
    NSMutableArray *handleList;
    NSUInteger i;
    
    handleList = [objectHandles objectForKey:aCanvasObject.uuid];
    if(!handleList){
        //選択されていないのでなにもしない
        return;
    }
    //ON -> OFF
    for(i = 0; i < handleList.count; i++){
        [((NSView *)[handleList objectAtIndex:i])removeFromSuperview];
    }
    [objectHandles removeObjectForKey:aCanvasObject.uuid];
    aCanvasObject.editHandleList = nil;
    [selectedObjects removeObject:aCanvasObject];
    [self checkEditingObject];
    [aCanvasObject deselected];
}

- (void)deselectAllCanvasObject
{
    NSMutableArray *handleList;
    NSUInteger i;
    
    for(id key in [objectHandles keyEnumerator]){
        handleList = [objectHandles objectForKey:key];
        for(i = 0; i < handleList.count; i++){
            [((NSView *)[handleList objectAtIndex:i])removeFromSuperview];
        }
    }
    [objectHandles removeAllObjects];
    for(CanvasObject *aCanvasObject in selectedObjects){
        aCanvasObject.editHandleList = nil;
        [aCanvasObject deselected];
    }
    [selectedObjects removeAllObjects];
    [self checkEditingObject];
}

- (void)deselectAllCanvasObjectExceptFor:(CanvasObject *)obj
{
    //面倒なので全部消してから再追加
    NSMutableArray *handleList, *handleListSaved;
    NSUInteger i;
    //保存
    handleListSaved = [objectHandles objectForKey:obj.uuid];
    //削除
    for(id key in [objectHandles keyEnumerator]){
        handleList = [objectHandles objectForKey:key];
        if(handleList != handleListSaved){
            for(i = 0; i < handleList.count; i++){
                [((NSView *)[handleList objectAtIndex:i])removeFromSuperview];
            }
        }
    }
    [objectHandles removeAllObjects];
    for(CanvasObject *aCanvasObject in selectedObjects){
        if(aCanvasObject != obj){
            aCanvasObject.editHandleList = nil;
            [aCanvasObject deselected];
        }
    }
    [selectedObjects removeAllObjects];
    //再追加
    if(handleListSaved){
        [objectHandles setValue:handleListSaved forKey:obj.uuid];
        [selectedObjects addObject:obj];
    }
    
    [self checkEditingObject];
}

- (BOOL)isSelectedCanvasObject:(CanvasObject *)aCanvasObject
{
    return [selectedObjects containsObject:aCanvasObject];
}

- (void)checkEditingObject
{
    //ひとつのオブジェクトだけが選択状態のとき、そのオブジェクトは編集対象となる。
    if(selectedObjects.count == 1){
        editingObject = [selectedObjects objectAtIndex:0];
        self.toolboxController.editingObject = editingObject;
        if([editingObject isKindOfClass:[CanvasObjectPaintFrame class]]){
            //ペイントフレームなので記録
            editingPaintFrame = (CanvasObjectPaintFrame *)editingObject;
        }
    } else{
        editingObject = nil;
        editingPaintFrame = nil;
        self.toolboxController.editingObject = nil;
    }
    [self setNeedsDisplay:YES];
}
@end
