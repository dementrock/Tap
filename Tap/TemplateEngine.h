//
//  TemplateEngine.h
//  Tap
//
//  Created by Rocky Duan on 5/2/14.
//  Copyright (c) 2014 Todd Ditchendorf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TemplateEngine : NSObject

- (NSString*) preParseFromString:(NSString*) input;
- (NSDictionary*) parseTemplateFromString:(NSString*) input;

@end
