//
//  TAPUIView.m
//  Tap
//
//  Created by Rocky Duan on 4/29/14.
//  Copyright (c) 2014 Tap. All rights reserved.
//

#import "UIView+TAPExtension.h"
#import "UIButton+NUI.h"
#import "UILabel+NUI.h"
#import "UIView+NUI.h"
#import "UIView+AutoLayout.h"
#define Val(obj) [obj nonretainedObjectValue]

@implementation UIView (TAPUIViewExtension)

- (UIButton*) addButtonWithArgs: (NSDictionary*) args {
    UIButton *button = [[UIButton alloc] initForAutoLayout];
    button.nuiClass = @"Button";
    [args enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"title"]) {
            [button setTitle:obj forState:UIControlStateNormal];
        } else if ([key isEqualToString:@"nuiClass"]) {
            button.nuiClass = obj;
        } else if ([key isEqualToString:@"as"]) {
            [self setValue:button forKey:obj];
        }
    }];
    [self addSubview:button];
    return button;
}

- (UILabel*) addLabelWithArgs: (NSDictionary*) args {
    UILabel *label = [[UILabel alloc] initForAutoLayout];
    label.numberOfLines = 0;
    label.nuiClass = @"Label";
    [args enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"text"]) {
            label.text = obj;
        } else if ([key isEqualToString:@"nuiClass"]) {
            label.nuiClass = obj;
        } else if ([key isEqualToString:@"as"]) {
            [self setValue:label forKey:obj];
        }
    }];
    [self addSubview:label];
    return label;
}

- (UIImageView*) addImageViewWithArgs: (NSDictionary*) args {
    UIImageView *imageView = [[UIImageView alloc] initForAutoLayout];
    imageView.image = [UIImage imageNamed:@"test.JPG"];
    [args enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isEqualToString:@"as"]) {
            [self setValue:imageView forKey:obj];
        }
    }];
    [self addSubview:imageView];
    return imageView;
}

@end

