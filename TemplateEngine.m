//
//  TemplateEngine.m
//  Tap
//
//  Created by Rocky Duan on 5/2/14.
//  Copyright (c) 2014 Todd Ditchendorf. All rights reserved.
//

#import "TemplateEngine.h"
#import "RegexKitLite.h"

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
    
    /*function preParse(jade) {
        var lines = jade.toString().split('\n');
        var stack = [];
        
        function last() {
            return stack[stack.length - 1] || 0;
        }
        
        for (var i = 0; i < lines.length; ++i) {
            var line = lines[i];
            if (!line || line.match(/^\s+$/)) {
                lines.splice(i, 1);
                i -= 1;
                continue;
            }
            var indent = line.match(/^[ ]+/)
            indent = indent ? indent[0] : '';
            lines[i] = lines[i].replace(/^[ ]+/, '');
            if (indent.length == last()) continue;
            if (indent.length > last()) {
                lines.splice(i, 0, '{INDENT:' + indent.length + '}');
                i += 1;
                stack.push(indent.length);
            } else {
                while (indent.length < last()) {
                    lines.splice(i, 0, '{DEDENT}');
                    i += 1;
                    stack.pop();
                }
            }
        }
        lines = lines.concat(stack.map(function() { return '{DEDENT}' }));
        lines = lines.join('\n');
        return lines;
    }*/
    
}

@end
