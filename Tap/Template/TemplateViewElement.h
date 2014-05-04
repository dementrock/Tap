//
//  TemplateViewElement.h
//  Tap
//
//  Created by Rocky Duan on 5/3/14.
//  Copyright (c) 2014 Sellegit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemplateViewElement : NSObject

@property (strong, nonatomic) NSString* viewId;
@property (strong, nonatomic) NSArray* viewClasses;
@property (strong, nonatomic) NSString* viewTag;
@property (strong, nonatomic) NSDictionary* attrs;

- (UIView*) createViewElementWithViewModel:(NSObject*)viewModel;

@end
