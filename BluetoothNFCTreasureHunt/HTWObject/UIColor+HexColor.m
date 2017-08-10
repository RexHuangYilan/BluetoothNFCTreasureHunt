//
//  UIColor+HexColor.m
//  ETMall
//
//  Created by Sean on 2015/8/12.
//  Copyright (c) 2015年 Hyxen. All rights reserved.
//

#import "UIColor+HexColor.h"

@implementation UIColor (HexColor)

+ (UIColor *)Color838383
{
    return [self colorForHex:@"838383"];
}

+ (UIColor *)ColorB3B3B3
{
    return [self colorForHex:@"B3B3B3"];
}

+ (UIColor *)ColorCB2530
{
    return [self colorForHex:@"CB2530"];
}

+ (UIColor *)Color970F0F
{
    return [self colorForHex:@"970F0F"];
}

+ (UIColor *)ColorCFCFD1
{
    return [self colorForHex:@"CFCFD1"];
}

+ (UIColor *)ColorF3F3F3
{
    return [self colorForHex:@"F3F3F3"];
}

+ (UIColor *)ColorF4F4F4
{
    return [self colorForHex:@"F4F4F4"];
}

+ (UIColor *)ColorCC0000
{
    return [self colorForHex:@"CC0000"];
}

+ (UIColor *)Color666666
{
    return [self colorForHex:@"666666"];
}

+ (UIColor *)Color999999
{
    return [self colorForHex:@"999999"];
}

+ (UIColor *)ColorAAAAAA
{
    return [self colorForHex:@"AAAAAA"];
}

+ (UIColor *)Color333333
{
    return [self colorForHex:@"333333"];
}

+ (UIColor *)ColorDEDEDE
{
    return [self colorForHex:@"DEDEDE"];
}

+ (UIColor *)ColorCCCCCC
{
    return [self colorForHex:@"CCCCCC"];
}

+ (UIColor *)ColorD91226
{
    return [self colorForHex:@"D91226"];
}

+ (UIColor *)ColorECECEC
{
    return [self colorForHex:@"ECECEC"];
}

+ (UIColor *)ColorFF6600
{
    return [self colorForHex:@"FF6600"];
}

+ (UIColor *)ColorCACACA
{
    return [self colorForHex:@"CACACA"];
}

+ (UIColor *)ColorE8E8E8
{
    return [self colorForHex:@"E8E8E8"];
}


+ (UIColor *)colorForHex:(NSString *)hexColor{
    hexColor = [[hexColor stringByTrimmingCharactersInSet:
                 [NSCharacterSet whitespaceAndNewlineCharacterSet]
                 ] uppercaseString];
    
    // String should be 6 or 7 characters if it includes '#'
    if ([hexColor length] < 6)
        return [UIColor blackColor];
    
    // strip # if it appears
    if ([hexColor hasPrefix:@"#"])
        hexColor = [hexColor substringFromIndex:1];
    
    // if the value isn't 6 characters at this point return
    // the color black
    if ([hexColor length] != 6)
        return [UIColor blackColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    NSString *rString = [hexColor substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [hexColor substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [hexColor substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
    
}

@end
