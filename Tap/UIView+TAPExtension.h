//
//  TAPUIView.h
//  Tap
//
//  Created by Rocky Duan on 4/29/14.
//  Copyright (c) 2014 Tap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (TAPUIViewExtension)

- (UIButton* ) addButtonWithArgs: (NSDictionary*)args;
- (UILabel* ) addLabelWithArgs: (NSDictionary*)args;
- (UIImageView* ) addImageViewWithArgs: (NSDictionary*)args;
@end