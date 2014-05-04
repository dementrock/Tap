//
//  UILabel+TemplateExtension.m
//  Tap
//
//  Created by Rocky Duan on 5/3/14.
//  Copyright (c) 2014 Sellegit Inc. All rights reserved.
//

#import "UILabel+TemplateExtension.h"
#import "UIView+TemplateExtension.h"
#import "../Template/TemplateViewElement.h"
#import "../Template/TemplateAttributeBinding.h"

@implementation UILabel (TemplateExtension)

- (id) initWithTemplateViewElement:(TemplateViewElement*)templateViewElement viewModel:(NSObject*)viewModel {
    self = [super initWithTemplateViewElement:templateViewElement viewModel:viewModel];
    if (self) {
        NSDictionary *attrs = templateViewElement.attrs;
        TemplateAttributeBinding *attrBinding;
        NSLog(@"attrs: %@", attrs);
        if ((attrBinding = attrs[@"text"]) != nil) {
            switch (attrBinding.bindType) {
                case kTemplateAttributeConstantBinding:
                    self.text = attrBinding.bindValue;
                    break;
                case kTemplateAttributeVariableBinding:
                    [self bindAttributeKeypath:@keypath(self, text) withViewModel:viewModel keyPath: attrBinding.bindValue];
                    break;
                default:
                    NSAssert(NO, @"Unrecognized attrBinding type: %@", @(attrBinding.bindType));
            }
        }
        
    }
    return self;   
}

@end
