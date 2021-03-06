//
//  SubCanvasView.h
//  FukoWorks
//
//  Created by 西田　耀 on 2014/01/18.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SubCanvasView : NSView
{

}

- (id)initWithFrame:(NSRect)frame;
- (void)drawRect:(NSRect)dirtyRect;

//
// Printing
//
- (NSSize)calculatePrintPaperSize;
- (BOOL)knowsPageRange:(NSRangePointer)range;
- (NSRect)rectForPage:(NSInteger)page;

@end
