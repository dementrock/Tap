//
//  LUISettings.m
//  Tap
//
//  Created by Rocky Duan on 4/30/14.
//  Copyright (c) 2014 Tap. All rights reserved.
//

#import "LUISettings.h"

static LUISettings *instance = nil;


@implementation LUISettings


+ (void) setAutoUpdatePath:(NSString*)path forView:(NSString*) viewName {
    
    instance = [self getInstance];
    //instance.
}

+ (LUISettings*) getInstance {
    
    @synchronized(self) {
        if (instance == nil) {
            instance = [LUISettings new];
        }
    }
    return instance;
}

@end
