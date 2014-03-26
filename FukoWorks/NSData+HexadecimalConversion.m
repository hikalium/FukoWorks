//
//  NSData+HexaDecimalConversion.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/06/12.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "NSData+HexadecimalConversion.h"

@implementation NSData (HexadecimalConversion)

- (NSString *)hexadecimalString
{
    //バイナリデータをHex文字列に変換
    const unsigned char *rawData;
    NSUInteger byteLength;
    NSMutableString *hexString;
    NSInteger i;
    
    rawData = (const unsigned char *)[self bytes];
    
    if(!rawData)
    {
        return [NSString string];
    }
    
    byteLength = [self length];
    hexString = [NSMutableString stringWithCapacity:byteLength * 2];
    
    for(i = 0; i < byteLength; i++){
        [hexString appendFormat:@"%02X ", rawData[i]];
    }
    
    return [NSString stringWithString:hexString];
}

- (id)initWithHexadecimalString:(NSString *)hexString
{
    unsigned char *rawData;
    const char *rawHexString;
    const char *invchar;
    NSInteger i;
    NSData *anData;
    NSUInteger dataLength;
    
    dataLength = [hexString length] / 3;
    rawHexString = [hexString UTF8String];
    rawData = malloc(dataLength);
    
    invchar = rawHexString;
    for(i = 0; i < dataLength; i++){
        if(*invchar == '\0'){
            break;
        }
        rawData[i] = strtol(invchar, (char **)&invchar, 16);
    }
    
    anData = [NSData dataWithBytes:rawData length:i];
    
    free(rawData);
    
    return anData;
}

@end
