//
//  Template.h
//  Tap
//
//  Created by Rocky Duan on 5/3/14.
//  Copyright (c) 2014 Sellegit Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Template : NSObject

@property (strong, nonatomic) NSArray* nodes;

- (void) buildView:(UIView*)view withViewModel:(NSObject*)viewModel;

@end