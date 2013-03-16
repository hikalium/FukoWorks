//
//  AppDelegate.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize label_indicator = _label_indicator;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //初期化
}

- (void)awakeFromNib
{
    //表示部分の初期化
    [self.label_indicator setStringValue:@"初期化完了"];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    //最後のwindowが閉じたときに終了するか否か
    return YES;
}

@end
