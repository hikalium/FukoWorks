//
//  SaveFileFWK.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/04/04.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainCanvasView.h"

@interface SaveFileFWK : NSObject
{
    MainCanvasView *sourceCanvas;
}

- (id)initWithCanvas:(MainCanvasView *)canvas;
- (void)writeCanvasToURL:(NSURL *)url atomically:(BOOL)isAtomically;

@end

@interface NSData (NSDataHexadecimalConversion)

- (NSString *)hexadecimalString;

@end
