//
//  CanvasObjectRectangle.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/17.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CanvasContext.h"
#import "MainCanvasView.h"

@interface CanvasObjectRectangle : NSView

- (id)initWithFrame:(NSRect)frame;
    //frameには、表示倍率100%換算のものを渡すこと。
- (void)drawRect:(NSRect)dirtyRect;
    //再描画時に呼ばれる。

@property (nonatomic) CanvasContext *objectContext;
    //オブジェクト固有のグラフィックコンテキストの設定を格納
@property (nonatomic) MainCanvasView *parentView;
    //所属するキャンバスへの参照

@end
