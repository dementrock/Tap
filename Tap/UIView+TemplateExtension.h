//
//  UIView+TemplateExtension.h
//  
//
//  Created by Rocky Duan on 5/3/14.
//
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static void * const kTemplateExtensionAssociatedViewIdKey = "viewId";
static void * const kTemplateExtensionAssociatedTemplateNameKey = "templateName";

@interface UIView (TemplateExtension)

@property (strong, nonatomic) NSString* viewId;
@property (strong, nonatomic) NSString* templateName;

- (id) initWithTemplate:(NSString*) templateName;
- (id) initWithTemplate:(NSString*) templateName andFrame:(CGRect) frame;
- (NSDictionary*) viewMap;

@end