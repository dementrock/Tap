//
//  TAPSellView.m
//  Tap
//
//  Created by Rocky Duan on 4/29/14.
//  Copyright (c) 2014 Tap. All rights reserved.
//

#import "TAPSellView.h"
#import "UIView+TAPExtension.h"
#import "PropertyInspector.h"
#import <NUIFileMonitor.h>
#import "UIView+NUI.h"
#import "UIView+AutoLayout.h"
#define WrapVal(obj) [NSValue valueWithNonretainedObject:(obj)]
#define NSWarning(s, ...) NSLog(@"Warning: %@", [NSString stringWithFormat:(s), ##__VA_ARGS__])

@interface TAPSellView ()

@property (strong, nonatomic) UIButton *submitButton;
@property (strong, nonatomic) UILabel *descriptionHintLabel;
@property (strong, nonatomic) UIImageView *previewImageView;
@property (strong, nonatomic) UITextView *descriptionInputView;
    
@end

@implementation TAPSellView

@synthesize submitButton;
@synthesize previewImageView;
@synthesize descriptionHintLabel;
@synthesize descriptionInputView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
//        [self constructView];
//        [self rerenderLayout];
//        [NUIFileMonitor watch:@"/Users/dementrock/coding/Tap/Tap/TAPSellView.vfl" withCallback:^(){
//            NSLog(@"file changed!");
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self rerenderLayout];
//            });
//        }];

            
    }
    
    return self;
}


- (void) constructView {
    [self addButtonWithArgs:@{
                              @"title": @"SUBMIT",
                              @"nuiClass": @"Button:Submit",
                              @"as": @"submitButton"
                              }];
    [self addImageViewWithArgs:@{ @"as": @"previewImageView"}];
    [self addLabelWithArgs:@{
                             @"text": @"Description: \n\n  - Item full name or URL Item full name or URL Item full name or URL\n  - Condition",
                             @"nuiClass": @"Label:Description",
                             @"as": @"descriptionHintLabel"
                             }];
    self.descriptionInputView = [[UITextView alloc] initForAutoLayout];
    [self addSubview:descriptionInputView];
}

- (void) addLayoutConstraint:(NSString*)str {
    
    
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
        //NSLog(@"%@", optionMap[layoutOption]);
        options = options | [optionMap[layoutOption] intValue];
    }
    NSString* strippedString = [regex stringByReplacingMatchesInString:compactStr options:0 range:NSMakeRange(0, compactStr.length) withTemplate:@"$1:"];
    
//    NSLog(@"stripped: %@", strippedString);
//    NSLog(@"final options: %@", @(options));
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:strippedString options:options metrics:@{} views:[self viewMap]]];
    
    
}

- (void) rerenderLayout {
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"TAPSellView" ofType:@"lss"];
//    NSAssert1(path != nil, @"File \"%@\" does not exist", @"TAPSellView");
    NSString* content = [NSString stringWithContentsOfFile:@"/Users/dementrock/Documents/Tap/Tap/TAPSellView.vfl" encoding:NSUTF8StringEncoding error:nil];
    //NSLog(@"%@", content);
    [self removeConstraints:self.constraints];
    for (NSString* line in [content componentsSeparatedByString:@"\n"]) {
        [self addLayoutConstraint:line];
    }
}

- (NSDictionary*) viewMap {
    NSMutableDictionary *viewMap = [[NSMutableDictionary alloc] init];

    [[PropertyInspector classPropsFor:[self class]] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
        if ([NSClassFromString(obj) isSubclassOfClass:[UIView class]]) {
            [viewMap setObject:[self valueForKey:key] forKey:key];
        }
    
    }];
    return [NSDictionary dictionaryWithDictionary:viewMap];
}

@end
