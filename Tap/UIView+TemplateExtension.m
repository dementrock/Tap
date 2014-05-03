//
//  UIView+TemplateExtension.m
//  
//
//  Created by Rocky Duan on 5/3/14.
//
//

#import "TemplateView.h"
#import "TemplateEngine.h"
#import "UIView+NUI.h"
#import "UIView+AutoLayout.h"

#import "UIButton+NUI.h"
#import "UILabel+NUI.h"
#import "UITextView+NUI.h"
#import "UITextField+NUI.h"
#import "UIView+TemplateExtension.h"
#import "UIView+LayoutExtension.h"

@implementation UIView (TemplateExtension)

@dynamic viewId;
@dynamic templateName;

- (void)setViewId:(NSString*)value
{
    objc_setAssociatedObject(self, kTemplateExtensionAssociatedViewIdKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)viewId{
    return objc_getAssociatedObject(self, kTemplateExtensionAssociatedViewIdKey);
}

- (void)setTemplateName:(NSString*)value
{
    objc_setAssociatedObject(self, kTemplateExtensionAssociatedTemplateNameKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)templateName{
    return objc_getAssociatedObject(self, kTemplateExtensionAssociatedTemplateNameKey);
}

- (id) initWithTemplate:(NSString *)templateName {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    return [self initWithTemplate:templateName andFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
}

- (id) initWithTemplate:(NSString*) templateName andFrame:(CGRect)frame{
    NSString* path = [[NSBundle mainBundle] pathForResource:templateName ofType:@"tpl"];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TemplateEngine *templateEngine = [[TemplateEngine alloc] init];
    NSDictionary *template = [templateEngine parseTemplateFromString:content];
    NSLog(@"now trying to initialize");
    self = [self initWithFrame:frame];
    NSLog(@"inited");
    if (self) {
        self.templateName = templateName;
        NSLog(@"view initialized!");
        //NSLog(@"parsed template: %@", template);
        [self buildViewFromTemplate:template];
        NSLog(@"view built!");
        NSLog(@"subviews: %@", self.subviews);
        NSLog(@"viewMap: %@", [self viewMap]);
        [self rerenderLayoutWithName:templateName andViewMap: [self viewMap]];
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
    } else if ([viewTag isEqualToString:@"TextView"]) {
        return [[UITextView alloc] initForAutoLayout];
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
        [viewMap addEntriesFromDictionary:subviewMap];
        if (subview.viewId != nil) {
            viewMap[subview.viewId] = subview;
        }
    }

    return [viewMap copy];
}

@end