//
//  TemplateAttributeBinding.h
//  Tap
//
//  Created by Rocky Duan on 5/3/14.
//  Copyright (c) 2014 Sellegit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum TemplateAttributeBindingType : NSUInteger {
    kTemplateAttributeVariableBinding,
    kTemplateAttributeConstantBinding,
} TemplateAttributeBindingType;

@interface TemplateAttributeBinding : NSObject

@property TemplateAttributeBindingType bindType;
@property (strong, nonatomic) id bindValue;

@end
