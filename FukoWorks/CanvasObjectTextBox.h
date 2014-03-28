//
//  CanvasObjectTextBox.h
//  FukoWorks
//
//  Created by 西田　耀 on 2014/02/02.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "CanvasObjectRectangle.h"

@interface CanvasObjectTextBox : CanvasObjectRectangle  <NSTextFieldDelegate>
- (void)controlTextDidChange:(NSNotification *)obj;
@end
