//
//  CanvasObjectBezierPath.h
//  FukoWorks
//
//  Created by 西田　耀 on 2014/04/02.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObject.h"

@interface CanvasObjectBezierPath : CanvasObject
@property (nonatomic) NSPoint p0;
@property (nonatomic) NSPoint p1;
@property (nonatomic) NSPoint cp0;
@property (nonatomic) NSPoint cp1;
@end
