//
//  NSColor+HexValueConversion.m
//  FukoWorks
//
//  Created by 西田　耀 on 2014/03/31.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "NSColor+HexValueConversion.h"

@implementation NSColor (HexValueConversion)
- (unsigned int)hexValue
{
    // r|g|b|a = abgr
    NSColor *tmpc;
    unsigned char c[4];
    
    tmpc = [self colorUsingColorSpaceName: NSDeviceRGBColorSpace];
    c[3] = (unsigned int)(tmpc.alphaComponent * 255.9999) & 0xff;
    c[2] = (unsigned int)(tmpc.blueComponent * 255.9999) & 0xff;
    c[1] = (unsigned int)(tmpc.greenComponent * 255.9999) & 0xff;
    c[0] = (unsigned int)(tmpc.redComponent * 255.9999) & 0xff;
    
   
    return *((unsigned int *)c);
}
@end
