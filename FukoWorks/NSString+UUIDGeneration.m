//
//  NSString+UUIDGeneration.m
//  FukoWorks
//
//  Created by 西田　耀 on 2014/01/19.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "NSString+UUIDGeneration.h"

@implementation NSString (UUIDGeneration)
+ (NSString *)UUID
{
    CFUUIDRef uuidObj = CFUUIDCreate(nil);//create a new UUID
    //get the string representation of the UUID
    CFStringRef uuidCFStr = CFUUIDCreateString(nil, uuidObj);
    NSString *uuidString = (__bridge NSString *)uuidCFStr;
    CFRelease(uuidObj);
    CFRelease(uuidCFStr);
    return uuidString;
}
@end
