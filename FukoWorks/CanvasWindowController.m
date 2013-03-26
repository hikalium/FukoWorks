//
//  CanvasWindowController.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/23.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasWindowController.h"

@implementation CanvasWindowController

@synthesize currentCanvasView = _currentCanvasView;

-(IBAction)comboBoxCanvasScaleChanged:(id)sender
{
    double scalePerCent, scale;
    
    scalePerCent = comboBoxCanvasScale.doubleValue;
    if(scalePerCent < 0){
        scalePerCent = 100;
    }
    scale = scalePerCent / 100;
    
    [label_indicator setStringValue:[NSString stringWithFormat:@"scaleSet:%f", scale]];
    [self.currentCanvasView setCanvasScale:scale];
}

@end
