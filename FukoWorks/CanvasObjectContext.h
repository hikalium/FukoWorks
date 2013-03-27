//
//  CanvasContext.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/20.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CanvasObjectContext : NSObject

@property (nonatomic) NSView *ControlView;

@property (nonatomic) CGColorRef FillColor;
@property (nonatomic) CGColorRef StrokeColor;
@property (nonatomic) CGFloat StrokeWidth;

@end
