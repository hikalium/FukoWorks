//
//  CanvasObjectRectangle.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/17.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CanvasContext.h"

@interface CanvasObjectRectangle : NSView

- (id)initWithFrame:(NSRect)frame;
- (void)drawRect:(NSRect)dirtyRect;

@property (nonatomic)CanvasContext *objectContext;

@end
