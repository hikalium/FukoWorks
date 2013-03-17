//
//  CanvasObjectRectangle.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/17.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectRectangle.h"

@implementation CanvasObjectRectangle
//矩形オブジェクト

//プロパティアクセッサメソッド
CGColorRef _FillColor;
- (CGColorRef)FillColor
{
    return _FillColor;
}
- (void)setFillColor:(CGColorRef)FillColor
{
    _FillColor = FillColor;
    [self setNeedsDisplay:YES];
}

//メソッド

- (id)initWithFrame:(NSRect)frame
{
    //エラーがあればnil, 成功したらselfを返す。
    if(frame.size.height < 0){
        NSRunAlertPanel(@"FukoWorks", @"大きさ0以下の四角形は描画できません。", @"OK", nil, nil);
        return nil;
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //再描画時に呼ばれる。
    CGContextRef mainContext;
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSetFillColorWithColor(mainContext, self.FillColor);
    CGContextFillRect(mainContext, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
}

@end
