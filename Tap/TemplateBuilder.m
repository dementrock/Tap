//
//  TemplateBuilder.m
//  Tap
//
//  Created by Rocky Duan on 5/2/14.
//  Copyright (c) 2014 Todd Ditchendorf. All rights reserved.
//

#import "TemplateBuilder.h"
#import "TemplateParser.h"
#import "Template/Template.h"
#import "Template/TemplateViewElement.h"
#import "Template/TemplateAttributeBinding.h"
#import "RegexKitLite.h"
#import <PEGKit/PEGKit.h>
#import <ReactiveCocoa.h>

@interface TemplateBuilder ()
- (NSString*) preParseFromString:(NSString*) input;
- (NSDictionary*) parseRawTemplateFromString:(NSString*) input;
@end


@implementation TemplateBuilder

- (NSString*) preParseFromString:(NSString*) input {
    
    NSMutableArray *stack = [[NSMutableArray alloc] init];
    NSArray *lines = [input componentsSeparatedByString:@"\n"];
    
    NSMutableArray *parsedLines = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < lines.count; ++i) {
        NSString* line = lines[i];
        if ([line isMatchedByRegex:@"^\\s+$"]) {
            continue;
        }
        NSString* indent = [line stringByMatching:@"^[ ]+"];
        line = [line stringByReplacingOccurrencesOfRegex:@"^[ ]+" withString:@""];
        if (indent.length > [stack.lastObject intValue]) {
            [parsedLines addObject:[NSString stringWithFormat:@"{INDENT}"]];
            [stack addObject:@(indent.length)];
        } else {
            while (indent.length < [stack.lastObject intValue]) {
                [parsedLines addObject:@"{DEDENT}"];
                [stack removeLastObject];
            }
        }
        [parsedLines addObject:line];
    }
    for (int i = 0; i < stack.count; ++i) {
        [parsedLines addObject:@"{DEDENT}"];
    }
    return [parsedLines componentsJoinedByString:@"\n{NEWLINE}\n"];
}

- (NSDictionary*) parseRawTemplateFromString:(NSString*) input {
    
    TemplateParser *parser = [[TemplateParser alloc] init];
    NSString* preparsedContent = [self preParseFromString:input];
    PKAssembly *result = [parser parseString:preparsedContent error:nil];
    NSArray *stack = [result objectsAbove:nil];
    return [stack firstObject];
}

- (Template*) buildTemplateFromString:(NSString *)input {
    NSDictionary* rawTemplate = [self parseRawTemplateFromString:input];
    Template* template = [[Template alloc] init];
    NSString *nodeType = rawTemplate[@"type"];
    NSAssert([nodeType isEqualToString:@"template"], @"Root node must be of type template");
    
    NSArray* values = rawTemplate[@"value"];
    template.nodes = [[values.rac_sequence map:^ id (NSDictionary* node) {
        NSString *subNodeType = node[@"type"];
        if ([subNodeType isEqualToString:@"viewElement"]) {
            return [self buildTemplateViewElementFromRaw: node];
        } else {
            NSAssert(NO, @"Unsupported node type: %@", subNodeType);
            return nil;
        }
    }] array];
    return template;
}

- (TemplateViewElement*) buildTemplateViewElementFromRaw:(NSDictionary*)node {
    NSAssert([node[@"type"] isEqualToString:@"viewElement"], @"type must be viewElement");
    
    TemplateViewElement* element = [[TemplateViewElement alloc] init];
    
    NSArray *values = node[@"value"];
    NSString* viewTag = [self findUniqueValueByType:@"viewTag" fromNodes:values];
    NSString* viewId = [self findUniqueValueByType:@"viewId" fromNodes:values];
    NSArray* viewClasses = [self findValuesByType:@"viewClass" fromNodes:values];
    
    element.viewTag = viewTag;
    element.viewId = viewId;
    element.viewClasses = viewClasses;
    
    NSArray* attrList = [self findUniqueValueByType:@"attrList" fromNodes:values orNil:YES];
    
    if (attrList != nil) {
        element.attrs = [self buildAttrsFromRaw:attrList];
    } else {
        element.attrs = @{};
    }
    return element;
}

- (NSDictionary*) buildAttrsFromRaw:(NSArray*)attrList {
    NSLog(@"attr list: %@", attrList);
    RACSequence *rac_attrList = [attrList.rac_sequence map:^id(NSDictionary* rawAttr) {
        return rawAttr[@"value"];
    }];
    NSArray* keys = [[rac_attrList map:^id(NSDictionary* attrNode) {
        return attrNode[@"attrName"];
    }] array];
    NSArray* values = [[rac_attrList map:^id(NSDictionary* attrNode) {
        return [self buildAttributeBindingFromRaw:attrNode[@"attrValue"]];
    }] array];
    return [NSDictionary dictionaryWithObjects:values forKeys:keys];
}

- (TemplateAttributeBinding*) buildAttributeBindingFromRaw:(NSDictionary *) raw{
    NSString* rawBindType = raw[@"type"];
    TemplateAttributeBinding *templateAttributeBinding = [[TemplateAttributeBinding alloc] init];
    templateAttributeBinding.bindValue = raw[@"value"];
    if ([rawBindType isEqualToString:@"variableBindingValue"]) {
        templateAttributeBinding.bindType = kTemplateAttributeVariableBinding;
    } else if ([rawBindType isEqualToString:@"constantBindingValue"]){
        templateAttributeBinding.bindType = kTemplateAttributeConstantBinding;
    } else {
        NSAssert(NO, @"Unrecognized attribute binding type: %@", rawBindType);
    }
    return templateAttributeBinding;
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

@end
