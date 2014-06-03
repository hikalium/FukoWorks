//
//  MainCanvasView+FWKFile.m
//  FukoWorks
//
//  Created by 西田　耀 on 2014/02/09.
//  Copyright (c) 2014年 TokyoGakugeiUniversitySeniorHighSchool. All rights reserved.
//

#import "MainCanvasView.h"

@implementation MainCanvasView (FWKFile)
//
//TypeID:data1a,data1b,data1c|data2a,data2b,data2c\n
//
- (void)writeCanvasToURL:(NSURL *)url atomically:(BOOL)isAtomically
{
    NSString *saveData;
    NSError *error;
    
    saveData = [self convertCanvasObjectsToString:self.canvasObjects];
    
    error = nil;
    if(![saveData writeToURL:url atomically:isAtomically encoding:NSUTF8StringEncoding error:&error]){
        NSRunAlertPanel(@"FukoWorks-Error-", @"%@", @"OK", nil, nil, [error localizedDescription]);
    }
}

- (NSString *)convertCanvasObjectsToString:(NSArray *)canvasObjects
{
    //渡されたNSArray中のCanvasObjectを示す文字列を生成し返す。
    CanvasObject *aCanvasObject;
    NSMutableString *stringRep;
    stringRep = [[NSMutableString alloc] initWithFormat:@"[FukoWorKs]:%ld\n", [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue]];
    
    for(NSView *aSubview in canvasObjects){
        if([aSubview isKindOfClass:[CanvasObject class]]){
            aCanvasObject = (CanvasObject *)aSubview;
            
            switch(aCanvasObject.ObjectType){
                case Rectangle:
                case Ellipse:
                case PaintFrame:
                case TextBox:
                case Line:
                case BezierPath:
                    [stringRep appendFormat:@"%ld:", aCanvasObject.ObjectType];
                    [stringRep appendFormat:@"%@\n",[aCanvasObject encodedStringForCanvasObject]];
                    break;
                default:
                    NSLog(@"Not implemented operation to save object type %ld.\n", aCanvasObject.ObjectType);
                    break;
            }
        }
    }
    
    return [NSString stringWithString:stringRep];
}

- (void)appendCanvasObjectsFromString:(NSString *)stringRep
{
    //渡された文字列からCanvasObjectを生成し追加する。
    NSArray *dataList;
    NSArray *dataItem;
    NSString *aDataString;
    NSString *dataItemsString;
    NSUInteger i, i_max;
    NSInteger formatVersion;
    CanvasObject *aCanvasObject;
    
    dataList = [stringRep componentsSeparatedByString:@"\n"];
    
    //Validation data.
    dataItemsString = [dataList objectAtIndex:0];
    dataItem = [dataItemsString componentsSeparatedByString:@":"];
    aDataString = [dataItem objectAtIndex:0];
    if(![aDataString isEqualToString:@"[FukoWorKs]"]){
        NSRunAlertPanel(@"FukoWorks-データ読み込みエラー-", @"ヘッダが見つかりません", @"OK", nil, nil);
        return;
    }
    aDataString = [dataItem objectAtIndex:1];
    formatVersion = aDataString.integerValue;
    if(formatVersion > [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] integerValue]){
        //もし新たなバージョンで作成されたファイルであったら、警告を出す。
        NSRunAlertPanel(@"FukoWorks-警告-", @"読み込もうとしているデータは、より新しいバージョンのFukoWorksで作成されたものであり、正常に読み込めない可能性があります。", @"OK", nil, nil);
    }
    
    // データ読み込み
    // バージョン判別をして適切な読み込みをする必要がある。
    i_max = [dataList count];
    for(i = 1; i < i_max; i++){
        dataItemsString = [dataList objectAtIndex:i];
        dataItem = [dataItemsString componentsSeparatedByString:@":"];
        aDataString = [dataItem objectAtIndex:0];
        aCanvasObject = nil;
        switch ((CanvasObjectType)aDataString.integerValue) {
            case Rectangle:
                aCanvasObject = [[CanvasObjectRectangle alloc] initWithEncodedString:[dataItem objectAtIndex:1]];
                break;
            case Ellipse:
                aCanvasObject = [[CanvasObjectEllipse alloc] initWithEncodedString:[dataItem objectAtIndex:1]];
                break;
            case PaintFrame:
                aCanvasObject = [[CanvasObjectPaintFrame alloc] initWithEncodedString:[dataItem objectAtIndex:1]];
                break;
            case TextBox:
                aCanvasObject = [[CanvasObjectTextBox alloc] initWithEncodedString:[dataItem objectAtIndex:1]];
                break;
            case Line:
                aCanvasObject = [[CanvasObjectLine alloc] initWithEncodedString:[dataItem objectAtIndex:1]];
                break;
            case BezierPath:
                aCanvasObject = [[CanvasObjectBezierPath alloc] initWithEncodedString:[dataItem objectAtIndex:1]];
                break;
            default:
                if([aDataString length] > 0){
                    NSLog(@"Not implemented operation to load object type %ld.\n", aDataString.integerValue);
                }
                break;
        }
        if(aCanvasObject != nil){
            [self addCanvasObject:aCanvasObject];
        }
    }
}

- (void)loadCanvasFromURL:(NSURL *)url
{
    NSString *dataString;
    NSError *error;
    
    error = nil;
    dataString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&error];
    
    [self appendCanvasObjectsFromString:dataString];
}
@end
