//
//  CanvasObjectHandling.h
//  FukoWorks
//
//  Created by 西田　耀 on 2014/01/19.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CanvasObjectHandling <NSObject>

@required
- (NSUInteger)numberOfEditHandlesForCanvasObject;

@optional
- (NSPoint)editHandlePointForHandleID:(NSUInteger)hid;
- (void)editHandleDown:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;
- (void)editHandleDragged:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;
- (void)editHandleUp:(NSPoint)currentHandlePointInCanvas forHandleID:(NSUInteger)hid;

@end
