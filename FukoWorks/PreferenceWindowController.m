//
//  PreferenceWindowController.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/03/26.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "PreferenceWindowController.h"

@implementation PrefernceWindow

- (void)cancelOperation:(id)sender
{
    //Escで閉じるための処理
    [self close];
}

- (BOOL)validateUserInterfaceItem:(id<NSValidatedUserInterfaceItem>)anItem
{
    if([anItem action] == @selector(toggleToolbarShown:)){
        return NO;
    }
    
    return [super validateUserInterfaceItem:anItem];
}

@end

@implementation PreferenceWindowController

PreferenceWindowController *sharedController = nil;
+ (PreferenceWindowController *)sharedPreferenceWindowController
{
    if(sharedController == nil) {
        sharedController = [[PreferenceWindowController alloc] init];
    }
    return sharedController;
}

- (id)init
{
    self = [super initWithWindowNibName:[self className]];
    if(self) {
        // Initialize
    }
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void)windowDidLoad
{    //初期設定
    NSToolbarItem *firstToolbarItem;
    
    [super windowDidLoad];
        
    firstToolbarItem = [[[[self window] toolbar] items] objectAtIndex:0];
    [[[self window] toolbar] setSelectedItemIdentifier:[firstToolbarItem itemIdentifier]];
    [self switchView:firstToolbarItem];
    [[self window] center];
}

- (void)switchView:(id)sender
{
    NSToolbarItem *toolbarItem;
    PreferenceViewType type;
    NSView *selectView = nil;
    NSArray *subviews;
    NSRect newFrameRect;
    NSRect oldFrameRect;
    
    if([sender isMemberOfClass:[NSToolbarItem class]]){
        toolbarItem = (NSToolbarItem *)sender;
        type = toolbarItem.tag;
        switch (type) {
            case General:
                selectView = settingViewGeneral;
                break;
            case Advanced:
                selectView = settingViewAdvanced;
                break;
            default:
                return;
        }
        
        subviews = [[[self window] contentView] subviews];
        for(NSView *aSubview in [subviews reverseObjectEnumerator]){
            [aSubview removeFromSuperview];
        }
        
        [[self window] setTitle:[toolbarItem label]];
        
        newFrameRect = [[self window] frameRectForContentRect:[selectView frame]];
        oldFrameRect = [[self window] frame];
        newFrameRect.origin.x = oldFrameRect.origin.x;
        newFrameRect.origin.y = oldFrameRect.origin.y + oldFrameRect.size.height - newFrameRect.size.height;
        [[self window] setFrame:newFrameRect display:YES animate:YES];
        
        [[[self window] contentView] addSubview:selectView];
        
    }
    
}

- (void)resetUserDefaults:(id)sender
{
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]];
    NSRunAlertPanel(@"FukoWorks", @"ユーザー設定を消去しました。", @"OK", nil, nil);
}

@end
