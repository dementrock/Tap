//
//  UIView+LayoutExtension.h
//  Tap
//
//  Created by Rocky Duan on 5/3/14.
//  Copyright (c) Sellegit Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LayoutExtension)

- (void) addLayoutConstraint:(NSString*)str withViewMap:(NSDictionary*)viewMap;

- (void) rerenderLayoutWithName:(NSString*)fileName andViewMap:(NSDictionary*) viewMap;
    
@end
