//
//  PreferenceWindowController.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/26.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PrefernceWindow : NSWindow

@end

@interface PreferenceWindowController : NSWindowController
{
    IBOutlet NSView *settingViewGeneral;
    IBOutlet NSView *settingViewAdvanced;
}

typedef enum : NSInteger {
    General = 1,
    Advanced = 2,
} PreferenceViewType;

+ (PreferenceWindowController *)sharedPreferenceWindowController;

- (IBAction)switchView:(id)sender;
- (IBAction)resetUserDefaults:(id)sender;

@end
