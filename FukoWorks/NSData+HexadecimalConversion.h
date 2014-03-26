//
//  NSData+HexaDecimalConversion.h
//  FukoWorks
//
//  Created by 西田　耀 on 13/06/12.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (HexadecimalConversion)
- (NSString *)hexadecimalString;
- (id)initWithHexadecimalString:(NSString *)hexString;
@end
