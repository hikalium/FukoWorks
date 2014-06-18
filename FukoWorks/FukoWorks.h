//
//  FukoWorks.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/05/11.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

//グローバル定数宣言

#ifndef FukoWorks_FukoWorks_h
#define FukoWorks_FukoWorks_h

typedef enum : NSInteger {
    Undefined = 0,
    Rectangle,
    Ellipse,
    PaintFrame,
    TextBox,
    Line,
    BezierPath,
    PaintToolsBase = 100,
    PaintRectangle,
    PaintEllipse,
    PaintPen,
    PaintLine,
    PaintFill
} CanvasObjectType;

#define FWK_PASTEBOARD_TYPE @"com.pcd.fwk.data.pasteboard"


#define FWK_MAX_SIZE_PIXEL              283465  // 100m (72ppi)
#define FWK_MIN_SIZE_PIXEL              1
#define FWK_MIN_SIZE_PIXEL_PAINTFRAME   16

#endif
