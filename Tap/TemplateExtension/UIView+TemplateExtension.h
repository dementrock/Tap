//
//  UIView+TemplateExtension.h
//  
//
//  Created by Rocky Duan on 5/3/14.
//
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <ReactiveCocoa.h>
#import "../Template/TemplateViewElement.h"

@interface UIView (TemplateExtension)

@property (strong, nonatomic) NSString *viewId;
@property (strong, nonatomic) NSString *templateName;
@property (strong, nonatomic) id<NSObject> viewModel;
@property (strong, nonatomic) NSString *syncValue;

- (id) initWithTemplate:(NSString*) templateName viewModel:(id<NSObject>) viewModel;
- (id) initWithTemplate:(NSString*) templateName viewModel:(id<NSObject>) viewModel frame:(CGRect) frame;
- (id) initWithTemplateViewElement:(TemplateViewElement*)templateViewElement viewModel:(NSObject*)viewModel;

- (NSDictionary*) viewMap;

- (void) bindAttributeKeypath:(NSString*) attributeKeypath withViewModel:(NSObject*)viewModel keyPath:(NSString*)viewModelKeypath;

@end