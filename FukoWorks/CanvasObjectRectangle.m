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
@synthesize objectContext = _objectContext;
@synthesize parentView = _parentView;

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
        self.objectContext = [[CanvasContext alloc] init];
        self.objectContext.ControlView = self;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    //再描画時に呼ばれる。
    CGContextRef mainContext;
    CGRect rect;
    
    mainContext = [[NSGraphicsContext currentContext] graphicsPort];
    
    rect = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    CGContextSaveGState(mainContext);
    {
        //CGContextScaleCTM(mainContext, self.parentView.canvasScale, self.parentView.canvasScale);
        CGContextSetFillColorWithColor(mainContext, self.objectContext.FillColor);
        CGContextFillRect(mainContext, rect);
        CGContextSetStrokeColorWithColor(mainContext, self.objectContext.StrokeColor);
        CGContextStrokeRectWithWidth(mainContext, rect, self.objectContext.StrokeWidth);
    }
    CGContextRestoreGState(mainContext);
}

@end
