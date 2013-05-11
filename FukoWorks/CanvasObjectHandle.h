//
//  CanvasObjectHandle.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/04/29.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CanvasObject.h"

@interface CanvasObjectHandle : NSView
{
    NSPoint moveHandleCursorOffset;
}

@property (nonatomic) CanvasObject *ownerCanvasObject;
@property (nonatomic) NSInteger tag;

- (id)initWithHandlePoint:(NSPoint)handlePoint;

@end
