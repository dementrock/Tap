//
//  UILabel+TemplateExtension.h
//  Tap
//
//  Created by Rocky Duan on 5/3/14.
//  Copyright (c) 2014 Sellegit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Template/TemplateViewElement.h"

@interface UILabel (TemplateExtension)

- (id) initWithTemplateViewElement:(TemplateViewElement*)templateViewElement viewModel:(NSObject*)viewModel;

@end
