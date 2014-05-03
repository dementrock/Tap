//
//  TemplateEngine.m
//  Tap
//
//  Created by Rocky Duan on 5/2/14.
//  Copyright (c) 2014 Todd Ditchendorf. All rights reserved.
//

#import "TemplateEngine.h"
#import "TemplateParser.h"
#import "RegexKitLite.h"
#import <PEGKit/PEGKit.h>

@implementation TemplateEngine

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

- (NSDictionary*) parseTemplateFromString:(NSString*) input {
    
    TemplateParser *parser = [[TemplateParser alloc] init];
    NSString* preparsedContent = [self preParseFromString:input];
    PKAssembly *result = [parser parseString:preparsedContent error:nil];
    NSArray *stack = [result objectsAbove:nil];
    return [stack firstObject];
}

@end
