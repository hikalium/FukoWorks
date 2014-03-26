//
//  NSColor+StringConversion.h
//  FukoWorks
//
//  Created by 西田　耀 on 2013/10/27.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (StringConversion)
- (NSString*)stringRepresentation;
+ (NSColor*)colorFromString:(NSString*)string forColorSpace:(NSColorSpace*)colorSpace;
@end
