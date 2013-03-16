//
//  AppDelegate.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/16.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong, nonatomic) IBOutlet NSTextField *label1;
@property (strong, nonatomic) IBOutlet NSButton *button1;

@end
