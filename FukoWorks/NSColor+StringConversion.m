//
//  NSColor+StringConversion.m
//  FukoWorks
//
//  Created by 西田　耀 on 2013/10/27.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "NSColor+StringConversion.h"

@implementation NSColor (StringConversion)
- (NSString*)stringRepresentation
{
    CGFloat components[10];
    NSColor *tmp;
    
    // 手抜き
    tmp = [self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
    
    [tmp getComponents:components];
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < [tmp numberOfComponents]; i++) {
        [string appendFormat:@"%f,", components[i]];
    }
    [string deleteCharactersInRange:NSMakeRange([string length]-1, 1)]; // trim the trailing space
    return string;
}

+ (NSColor*)colorFromString:(NSString*)string forColorSpace:(NSColorSpace*)colorSpace
{
    CGFloat components[10];    // doubt any color spaces need more than 10 components
    NSArray *componentStrings = [string componentsSeparatedByString:@","];
    NSUInteger count = [componentStrings count];
    NSColor *color = nil;
    if (count <= 10) {
        for (NSUInteger i = 0; i < count; i++) {
            components[i] = [[componentStrings objectAtIndex:i] floatValue];
        }
        color = [NSColor colorWithColorSpace:colorSpace components:components count:count];
    }
    return color;
}
@end
