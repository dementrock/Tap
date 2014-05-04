//
//  TemplateViewElement.m
//  Tap
//
//  Created by Rocky Duan on 5/3/14.
//  Copyright (c) 2014 Sellegit Inc. All rights reserved.
//

#import "TemplateViewElement.h"
#import "../TemplateExtension/UIView+TemplateExtension.h"

@implementation TemplateViewElement

@synthesize viewId;
@synthesize viewClasses;
@synthesize viewTag;
@synthesize attrs;

- (UIView*) createViewElementWithViewModel:(NSObject*)viewModel {
    // TODO process subviews
    if ([viewTag isEqualToString:@"TextField"]) {
        return [[UITextField alloc] initWithTemplateViewElement:self viewModel:viewModel];
    } else if ([viewTag isEqualToString:@"TextView"]) {
        return [[UITextView alloc] initWithTemplateViewElement:self viewModel:viewModel];
    } else if ([viewTag isEqualToString:@"Label"]) {
        return [[UILabel alloc] initWithTemplateViewElement:self viewModel:viewModel];
    } else {
        NSAssert(NO, ([NSString stringWithFormat:@"Unsupported viewTag: ", viewTag]));
        return nil;
    }   
}

@end