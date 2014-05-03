//
//  PropertyInspector.h
//  Tap
//
//  Created by Rocky Duan on 4/30/14.
//  Copyright (c) 2014 Tap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropertyInspector : NSObject

+ (NSDictionary *)classPropsFor:(Class)klass;

@end