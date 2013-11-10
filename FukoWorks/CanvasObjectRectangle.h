//
//  CanvasObjectRectangle.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/17.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CanvasObjectRectFrameBase.h"

@interface CanvasObjectRectangle : CanvasObjectRectFrameBase
{

}

- (id)initWithFrame:(NSRect)frameRect;
- (void)drawRect:(NSRect)dirtyRect;

@end
