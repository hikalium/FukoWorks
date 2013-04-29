//
//  SaveFileFWK.m
//  FukoWorks
//
//  Created by 西田　耀 on 13/04/04.
//  Copyright (c) 2013年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "SaveFileFWK.h"

@implementation SaveFileFWK

- (id)init
{
    sourceCanvas = nil;
    
    return self;
}

- (id)initWithCanvas:(MainCanvasView *)canvas
{
    self = [self init];
    
    if(self){
        sourceCanvas = canvas;
    }
    
    return self;
}

- (void)writeCanvasToURL:(NSURL *)url atomically:(BOOL)isAtomically
{
    NSMutableString *saveData;
    NSString *canvasObjectName;
    NSInteger count;
    CanvasObject *aCanvasObject;
    NSError *error;
    
    if(sourceCanvas){
        saveData = [[NSMutableString alloc] initWithFormat:@"[FukoWorKs] BundleVersion:%ld\n", [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue]];
        
        count = 0;
        for(NSView *aSubview in sourceCanvas.subviews){
            if([aSubview isKindOfClass:[CanvasObject class]]){
                aCanvasObject = (CanvasObject *)aSubview;
                canvasObjectName = [NSString stringWithFormat:@"%ld", count];
                [saveData appendFormat:@"%@:", canvasObjectName];
                switch(aCanvasObject.ObjectType){
                    case Undefined:
                        [saveData appendString:@"Undefined:"];
                        break;
                    case Rectangle:
                        [saveData appendString:@"Rectangle:"];
                        break;
                    case Ellipse:
                        [saveData appendString:@"Ellipse:"];
                        break;
                }
                [saveData appendFormat:@"%@\n",[aCanvasObject encodedStringForObject]];
                count++;
            }
        }

        error = nil;
        if(![saveData writeToURL:url atomically:isAtomically encoding:NSUTF8StringEncoding error:&error]){
            NSRunAlertPanel(@"FukoWorks-Error-", [error localizedDescription], @"OK", nil, nil);
        }
    }
}
@end

@implementation NSData (NSDataHexadecimalConversion)

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

- (id)initWithHexadecimalString:(NSString *)hexString length:(NSUInteger)length
{
    unsigned char *rawData;
    const char *rawHexString;
    const char *invchar;
    NSInteger i;
    NSData *anData;
    
    rawData = malloc([self length]);
    rawHexString = [hexString UTF8String];
    
    invchar = rawHexString;
    for(i = 0; i < length; i++){
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
