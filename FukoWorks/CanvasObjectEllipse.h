//
//  CanvasObjectEllipse.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/28.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectRectFrameBase.h"

@interface CanvasObjectEllipse : CanvasObjectRectFrameBase
{
    
}

- (id)initWithFrame:(NSRect)frameRect;
- (void)drawRect:(NSRect)dirtyRect;

@end
