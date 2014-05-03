//
//  TAPUIViewController.m
//  Tap
//
//  Created by Rocky Duan on 4/29/14.
//  Copyright (c) 2014 Tap. All rights reserved.
//

#import "TAPUIViewController.h"

@interface TAPUIViewController ()

@end

@implementation TAPUIViewController

- (UIView*) createFullScreenViewWithClass:(Class)klass {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    UIView *view = [[klass alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    self.view = view;
    return view;
}
@end