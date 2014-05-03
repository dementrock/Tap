//
//    TemplateView.m
//    Tap
//
//    Created by Rocky Duan on 5/1/14.
//    Copyright (c) 2014 Tap. All rights reserved.
//

#import "TemplateView.h"
#import "TemplateEngine.h"
#import "UIView+NUI.h"
#import "UIView+AutoLayout.h"
#import "UIView+TemplateExtension.h"

@implementation TemplateView

- (id) initWithTemplate:(NSString*) templateName andFrame:(CGRect)frame{
    NSString* path = [[NSBundle mainBundle] pathForResource:templateName ofType:@"tpl"];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TemplateEngine *templateEngine = [[TemplateEngine alloc] init];
    NSDictionary *template = [templateEngine parseTemplateFromString:content];
    NSLog(@"now trying to initialize");
    self = [super initWithFrame:frame];
    NSLog(@"inited");
    if (self) {
        NSLog(@"view initialized!");
        //NSLog(@"parsed template: %@", template);
        [self buildViewFromTemplate:template];
        NSLog(@"view built!");
        NSLog(@"subviews: %@", self.subviews);
    }
    return self;
}

- (void) buildViewFromTemplate:(NSDictionary*)template {
    //[self.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
    [self buildView: self fromTemplateNode:template];
}

- (void) buildView:(UIView*)view fromNode:(NSDictionary*)node {
    NSString *nodeType = node[@"type"];
    if ([nodeType isEqualToString:@"viewElement"]) {
        [self buildViewElementForSuperView:view fromNode:node];
    } else {
        NSLog(@"Unsupported node type: %@", nodeType);
    }
}

- (NSArray*) filterNodes:(NSArray*)nodes byType:(NSString*)type {
    return [[nodes.rac_sequence filter: ^ BOOL (NSDictionary* node) {
        return [node[@"type"] isEqualToString:type];
    }] array];
}

- (id) findUniqueValueByType:(NSString*)type fromNodes:(NSArray*) nodes {
    return [self findUniqueValueByType:type fromNodes:nodes orNil:false];
}

- (id) findUniqueValueByType:(NSString*)type fromNodes:(NSArray*) nodes orNil:(BOOL)orNil {
    NSArray* filteredNodes = [self filterNodes:nodes byType:type];
    if (orNil) {
        NSAssert(filteredNodes.count <= 1, ([NSString stringWithFormat:@"Must have at most one %@ element", type]));
    } else {
        NSAssert(filteredNodes.count == 1, ([NSString stringWithFormat:@"Must have exactly one %@ element", type]));
    }
    NSDictionary* firstNode = [filteredNodes firstObject];
    if (firstNode == nil) {
        return nil;
    } else {
        id value = [filteredNodes firstObject][@"value"];
        return value;
    }
}

- (NSArray*) findValuesByType:(NSString*)type fromNodes:(NSArray*) nodes {
    NSArray* filteredNodes = [self filterNodes:nodes byType:type];
    return [[filteredNodes.rac_sequence map:^(NSDictionary* node) {
        return node[@"value"];
    }] array];
}

- (void) buildViewElementForSuperView:(UIView*)view fromNode:(NSDictionary*)node {
    NSLog(@"building view element...");
    NSArray *values = node[@"value"];
    
    NSString* viewTag = [self findUniqueValueByType:@"viewTag" fromNodes:values];
    NSLog(@"viewTag: %@", viewTag);
    
    NSString* viewId = [self findUniqueValueByType:@"viewId" fromNodes:values];
    NSLog(@"viewId: %@", viewId);
    
    NSArray* viewClasses = [self findValuesByType:@"viewClass" fromNodes:values];
    NSArray* attrList = [self findUniqueValueByType:@"attrList" fromNodes:values orNil:YES];
    
    UIView* viewElement = [self constructViewElementFromViewTag:viewTag];
    
    viewElement.viewId = viewId;
    
    [view addSubview:viewElement];
}

- (UIView*) constructViewElementFromViewTag:(NSString*)viewTag {
    if ([viewTag isEqualToString:@"TextField"]) {
        return [[UITextField alloc] initForAutoLayout];
    } else if ([viewTag isEqualToString:@"Label"]) {
        return [[UILabel alloc] initForAutoLayout];
    } else {
        NSAssert(NO, ([NSString stringWithFormat:@"Unsupported viewTag: ", viewTag]));
        return nil;
    }
}

- (void) buildView:(UIView*)view fromTemplateNode:(NSDictionary*)template {
    NSString *nodeType = template[@"type"];
    NSAssert([nodeType isEqualToString:@"template"], @"Root node must be of type template");
    for (NSDictionary *node in template[@"value"]) {
        [self buildView:view fromNode: node];
    }
}

- (NSDictionary*) viewMap {
    NSMutableDictionary *viewMap = [[NSMutableDictionary alloc] init];
    for (UIView* subview in self.subviews) {
        NSDictionary* subviewMap = [subview viewMap];
    }

    return [viewMap copy];
}



@end