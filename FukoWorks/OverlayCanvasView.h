//
//  OverlayCanvasView.h
//  FukoWorks
//
//  Created by 西田　耀 on 2013/11/24.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface OverlayCanvasView : NSView
{
    CGColorRef highlightColor;
}

@property (nonatomic) NSArray *canvasObjectList;

@end
