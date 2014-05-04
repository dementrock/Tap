//
//  SellViewModel.m
//  Tap
//
//  Created by Rocky Duan on 5/3/14.
//  Copyright (c) 2014 Sellegit Inc. All rights reserved.
//

#import "TAPSellViewModel.h"

@implementation TAPSellViewModel
@synthesize syncValue;

- (id) init {
    self = [super init];
    if (self) {
        self.syncValue = [[NSString alloc] init];
        self.syncValue2 = [[NSString alloc] init];
    }
    return self;
}

@end
