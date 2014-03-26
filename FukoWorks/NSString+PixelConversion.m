//
//  NSString+PixelConversion.m
//  FukoWorks
//
//  Created by 西田　耀 on 2013/10/26.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "NSString+PixelConversion.h"

@implementation NSString (PixelConversion)

#define VALUE_INCH  2.54    //cm
#define SCALE_PPI   72

- (CGFloat)convertPixelUnitWithDefaultValue:(CGFloat)defaultValue
{
    //72ppi(Quartz2D座標系標準単位)として、文字列をピクセル指定に変換する
    char *p;
    CGFloat value = strtod([self UTF8String], &p);
    NSString *suffix = [[NSString alloc] initWithCString:p encoding:NSUTF8StringEncoding];

    if(*p == '\0' || [suffix isEqualToString:@"px"]){
        //文字列全部が変換された場合はpxとして扱う
        return value;
    }
    if([suffix isEqualToString:@"cm"]){
        return (SCALE_PPI * value / VALUE_INCH);
    }
    if([suffix isEqualToString:@"mm"]){
        return (SCALE_PPI * value / VALUE_INCH / 10);
    }
    if([suffix isEqualToString:@"m"]){
        return (SCALE_PPI * value / VALUE_INCH * 100);
    }

    //識別できない接尾辞だったときは、引数で指定されたデフォルトの値を返す
    return defaultValue;
}
@end
