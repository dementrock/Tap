//
//  TemplateBuilder.h
//  Tap
//
//  Created by Rocky Duan on 5/2/14.
//  Copyright (c) 2014 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Template.h"

@interface TemplateBuilder : NSObject

- (Template*) buildTemplateFromString:(NSString*) input;

@end
