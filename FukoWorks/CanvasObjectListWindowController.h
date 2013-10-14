//
//  CanvasObjectListWindowController.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/10/13.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "FukoWorks.h"
#import "MainCanvasView.h"

@interface CanvasObjectListWindowController : NSWindowController <NSOutlineViewDelegate, NSOutlineViewDataSource>
{
    IBOutlet NSPanel *listPanel;
    IBOutlet NSOutlineView *outlineView;
}

+ (CanvasObjectListWindowController *)sharedCanvasObjectListWindowController;

@property (nonatomic) MainCanvasView *currentCanvas;

- (void)reloadData;

@end
