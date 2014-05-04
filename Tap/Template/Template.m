//
//  Template.m
//  Tap
//
//  Created by Rocky Duan on 5/3/14.
//  Copyright (c) 2014 Sellegit Inc. All rights reserved.
//

#import "Template.h"
#import "TemplateViewElement.h"

@implementation Template

@synthesize nodes;

- (void) buildView:(UIView*)view withViewModel: (NSObject*)viewModel{
    [view.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    for (TemplateViewElement* node in self.nodes) {
        [view addSubview:[node createViewElementWithViewModel:viewModel]];
    }
}

@end
