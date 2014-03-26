//
//  MainCanvasView+Sorting.m
//  FukoWorks
//
//  Created by 西田　耀 on 2014/01/19.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "MainCanvasView.h"

@implementation MainCanvasView (Sorting)
//
// Sorting
//

- (void)moveCanvasObjects:(NSArray *)mcoList aboveOf:(CanvasObject *)coBelow
{
    //coBelow == nilの時は、一番下に追加することを示す。
    NSUInteger i, coBelowIndex;
    CanvasObject *co;
    
    for(i = 0; i < mcoList.count; i++){
        co = mcoList[i];
        [co removeFromSuperview];
        [self.canvasObjects removeObject:co];
    }
    coBelowIndex = [self.canvasObjects indexOfObject:coBelow];
    if(coBelow && coBelowIndex == NSNotFound){
        return;
    }
    for(i = 0; i < mcoList.count; i++){
        co = mcoList[i];
        if(coBelow){
            [rootSubCanvas addSubview:co positioned:NSWindowAbove relativeTo:coBelow];
            [self.canvasObjects insertObject:co atIndex:coBelowIndex + 1];
        } else{
            [rootSubCanvas addSubview:co positioned:NSWindowBelow relativeTo:nil];
            [self.canvasObjects insertObject:co atIndex:0];
        }
    }
}

- (BOOL)bringCanvasObjectToFront:(CanvasObject *)aCanvasObject
{
    //一段階上に持ってくる
    //retv:isChanged
    NSUInteger index = [self.canvasObjects indexOfObject:aCanvasObject];
    if(index == self.canvasObjects.count - 1){
        //すでに最前面なので何もしない
        return NO;
    }
    if(index == NSNotFound){
        return NO;
    }
    CanvasObject *coBelow = [self.canvasObjects objectAtIndex:index + 1];
    [aCanvasObject removeFromSuperview];
    [rootSubCanvas addSubview:aCanvasObject positioned:NSWindowAbove relativeTo:coBelow];
    [self.canvasObjects exchangeObjectAtIndex:index withObjectAtIndex:index + 1];
    return YES;
}

- (BOOL)bringCanvasObjectToBack:(CanvasObject *)aCanvasObject
{
    //一段階後ろにもっていく
    //retv:isChanged
    NSUInteger index = [self.canvasObjects indexOfObject:aCanvasObject];
    if(index == 0){
        //すでに最背面なので何もしない
        return NO;
    }
    if(index == NSNotFound){
        return NO;
    }
    CanvasObject *coAbove = [self.canvasObjects objectAtIndex:index - 1];
    [aCanvasObject removeFromSuperview];
    [self addSubview:aCanvasObject positioned:NSWindowBelow relativeTo:coAbove];
    [self.canvasObjects exchangeObjectAtIndex:index withObjectAtIndex:index - 1];
    return YES;
}
@end
