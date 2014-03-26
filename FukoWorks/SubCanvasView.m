//
//  SubCanvasView.m
//  FukoWorks
//
//  Created by 西田　耀 on 2014/01/18.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "SubCanvasView.h"

@implementation SubCanvasView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
}

//
// Printing
//

// https://developer.apple.com/library/mac/documentation/cocoa/conceptual/Printing/osxp_pagination/osxp_pagination.html
- (NSSize)calculatePrintPaperSize
{
    //用紙の大きさを取得
    NSPrintInfo *pinfo = [[NSPrintOperation currentOperation] printInfo];
    
    NSSize paperSize = [pinfo paperSize];
    
    float pageHeight = paperSize.height - [pinfo topMargin] - [pinfo bottomMargin];
    float pageWidth = paperSize.width - [pinfo leftMargin] - [pinfo rightMargin];
    
    float scale = [[[pinfo dictionary] objectForKey:NSPrintScalingFactor]
                   floatValue];
    
    return NSMakeSize(pageWidth / scale, pageHeight / scale);
    
}

- (BOOL)knowsPageRange:(NSRangePointer)range
{
    //必要なページ数をrangeに設定
    NSSize paperSize = [self calculatePrintPaperSize];
    CGFloat pages;
    pages = ceil(self.frame.size.width / paperSize.width) * ceil(self.frame.size.height / paperSize.height);
    *range = NSMakeRange(1, pages);
    //NSLog(@"pages:%f", pages);
    
    return YES;
}

- (NSRect)rectForPage:(NSInteger)page
{
    //指定されたページ番号に該当するview上の範囲を返す。
    NSInteger xpages, ypages, x, y;
    NSSize paperSize = [self calculatePrintPaperSize];
    NSRect rect;
    xpages = ceil(self.frame.size.width / paperSize.width);
    ypages = ceil(self.frame.size.height / paperSize.height);
    if(page > xpages * ypages){
        //範囲外のページ番号だった
        //NSLog(@"zerorect:");
        return NSZeroRect;
    }
    page--;
    y = (page / xpages);
    x = (page % xpages);
    
    rect = NSMakeRect(paperSize.width * x, paperSize.height * y,
                      paperSize.width, paperSize.height);
    //NSLog(@"rect:%@", NSStringFromRect(rect));
    
    return rect;
}

@end
