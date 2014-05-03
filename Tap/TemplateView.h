//
//  TemplateView.h
//  Tap
//
//  Created by Rocky Duan on 5/1/14.
//  Copyright (c) 2014 Tap. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TemplateView : UIView

- (id) initWithTemplate:(NSString*) templateName andFrame:(CGRect) frame;

- (NSDictionary*) viewMap;

@end