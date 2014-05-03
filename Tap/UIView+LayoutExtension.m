//
//  UIView+LayoutExtension.m
//  Tap
//
//  Created by Rocky Duan on 5/3/14.
//  Copyright (c) 2014 Sellegit Inc. All rights reserved.
//

#import "UIView+LayoutExtension.h"

#define NSWarning(s, ...) NSLog(@"Warning: %@", [NSString stringWithFormat:(s), ##__VA_ARGS__])

@implementation UIView (LayoutExtension)

- (void) addLayoutConstraint:(NSString*)str withViewMap:(NSDictionary*)viewMap {
    
    NSString* compactStr = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (![str hasPrefix:@"V"] && ![str hasPrefix:@"H"]) {
        NSWarning(@"Layout constraint must begin with either V or H. Layout constrait %@ ignored.", str);
        return;
    }
    
    // Parse layout option..
    // L(eft), R(ight), T(op), B(ottom), LEAD(ing), TRAIL(ing), C(enter)X, C(enter)Y, BASE(line);
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^([V|H])\\((.*?)\\):" options:0 error:&error];
    if (error) {
        NSWarning(@"Couldn't create regular expression. Layout constraint %@ ignored.", str);
        return;
    }
    NSTextCheckingResult* matchResult = [regex firstMatchInString:compactStr options:0 range:NSMakeRange(0, compactStr.length)];
    NSRange matchRange = [matchResult rangeAtIndex:2];
    NSArray* layoutOptions = [[compactStr substringWithRange:matchRange] componentsSeparatedByString:@","];
    if ([layoutOptions count] == 0) {
        NSWarning(@"No layout option found. Layout constraint %@ ignored.", str);
        return;
    }
    NSDictionary* optionMap = @{
        @"L": @(NSLayoutFormatAlignAllLeft),
        @"R": @(NSLayoutFormatAlignAllRight),
        @"T": @(NSLayoutFormatAlignAllTop),
        @"B": @(NSLayoutFormatAlignAllBottom),
        @"LEAD": @(NSLayoutFormatAlignAllLeading),
        @"TRAIL": @(NSLayoutFormatAlignAllTrailing),
        @"CX": @(NSLayoutFormatAlignAllCenterX),
        @"CY": @(NSLayoutFormatAlignAllCenterY),
        @"BASE": @(NSLayoutFormatAlignAllBaseline),
    };
    
    NSLayoutFormatOptions options = 0;
    for (NSString* layoutOption in layoutOptions) {
        
        if (optionMap[layoutOption] == nil) {
            NSWarning(@"Unrecognized layout option %@. Layout constraint %@ ignored.", layoutOption, str);
            return;
        }
        options = options | [optionMap[layoutOption] intValue];
    }
    NSString* strippedString = [regex stringByReplacingMatchesInString:compactStr options:0 range:NSMakeRange(0, compactStr.length) withTemplate:@"$1:"];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:strippedString options:options metrics:@{} views:viewMap]];
}

- (void) rerenderLayoutWithName:(NSString*)fileName andViewMap:(NSDictionary*) viewMap {
    NSString *path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"vfl"];
    NSAssert(path != nil, @"File \"%@.vfl\" does not exist", fileName);
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self removeConstraints:self.constraints];
    for (NSString* line in [content componentsSeparatedByString:@"\n"]) {
        [self addLayoutConstraint:line withViewMap:viewMap];
    }
}
@end