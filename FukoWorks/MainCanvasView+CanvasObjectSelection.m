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
        //Shiftキーを押していないので、現在の選択を全て解除
        [self deselectAllCanvasObject];
    }
    if(!aCanvasObject || [objectHandles objectForKey:aCanvasObject.uuid]){
        //すでに選択されている
        if(([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask)){
            //Shiftキーが押されている場合は選択解除
            [self deselectCanvasObject:aCanvasObject];
        }
        return;
    }
    NSUInteger handles = [aCanvasObject numberOfEditHandlesForCanvasObject];
    if(handles != 0){
        [objectHandles setValue:[NSMutableArray array] forKey:aCanvasObject.uuid];
        [self resetCanvasObjectHandleForCanvasObject:aCanvasObject];
    }
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
            [self.superview addSubview:anEditHandle];
        }
        [objectHandles setValue:handleList forKey:aCanvasObject.uuid];
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
    for(i = 0; i < handleList.count; i++){
        [((NSView *)[handleList objectAtIndex:i])removeFromSuperview];
    }
    [objectHandles removeObjectForKey:aCanvasObject.uuid];
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
}

- (BOOL)isSelectedCanvasObject:(CanvasObject *)aCanvasObject
{
    return ([objectHandles objectForKey:aCanvasObject.uuid] != nil);
}
@end
