#import "TemplateParser.h"
#import <PEGKit/PEGKit.h>

#define LT(i) [self LT:(i)]
#define LA(i) [self LA:(i)]
#define LS(i) [self LS:(i)]
#define LF(i) [self LD:(i)]

#define POP()        [self.assembly pop]
#define POP_STR()    [self popString]
#define POP_TOK()    [self popToken]
#define POP_BOOL()   [self popBool]
#define POP_INT()    [self popInteger]
#define POP_DOUBLE() [self popDouble]

#define PUSH(obj)      [self.assembly push:(id)(obj)]
#define PUSH_BOOL(yn)  [self pushBool:(BOOL)(yn)]
#define PUSH_INT(i)    [self pushInteger:(NSInteger)(i)]
#define PUSH_DOUBLE(d) [self pushDouble:(double)(d)]

#define PUSH_TAG(type, value) [self.assembly push: [NSDictionary dictionaryWithObjects: @[type, value] forKeys: @[@"type", @"value"]]];

#define EQ(a, b) [(a) isEqual:(b)]
#define NE(a, b) (![(a) isEqual:(b)])
#define EQ_IGNORE_CASE(a, b) (NSOrderedSame == [(a) compare:(b)])

#define MATCHES(pattern, str)               ([[NSRegularExpression regularExpressionWithPattern:(pattern) options:0                                  error:nil] numberOfMatchesInString:(str) options:0 range:NSMakeRange(0, [(str) length])] > 0)
#define MATCHES_IGNORE_CASE(pattern, str)   ([[NSRegularExpression regularExpressionWithPattern:(pattern) options:NSRegularExpressionCaseInsensitive error:nil] numberOfMatchesInString:(str) options:0 range:NSMakeRange(0, [(str) length])] > 0)

#define ABOVE(fence) [self.assembly objectsAbove:(fence)]

#define LOG(obj) do { NSLog(@"%@", (obj)); } while (0);
#define PRINT(str) do { printf("%s\n", (str)); } while (0);

@interface PKParser ()
@property (nonatomic, retain) NSMutableDictionary *tokenKindTab;
@property (nonatomic, retain) NSMutableArray *tokenKindNameTab;
@property (nonatomic, retain) NSString *startRuleName;
@property (nonatomic, retain) NSString *statementTerminator;
@property (nonatomic, retain) NSString *singleLineCommentMarker;
@property (nonatomic, retain) NSString *blockStartMarker;
@property (nonatomic, retain) NSString *blockEndMarker;
@property (nonatomic, retain) NSString *braces;

- (BOOL)popBool;
- (NSInteger)popInteger;
- (double)popDouble;
- (PKToken *)popToken;
- (NSString *)popString;

- (void)pushBool:(BOOL)yn;
- (void)pushInteger:(NSInteger)i;
- (void)pushDouble:(double)d;
@end

@interface TemplateParser ()
@property (nonatomic, retain) NSMutableDictionary *template_memo;
@property (nonatomic, retain) NSMutableDictionary *expression_memo;
@property (nonatomic, retain) NSMutableDictionary *line_memo;
@property (nonatomic, retain) NSMutableDictionary *subBlock_memo;
@property (nonatomic, retain) NSMutableDictionary *indent_memo;
@property (nonatomic, retain) NSMutableDictionary *dedent_memo;
@property (nonatomic, retain) NSMutableDictionary *element_memo;
@property (nonatomic, retain) NSMutableDictionary *viewElement_memo;
@property (nonatomic, retain) NSMutableDictionary *tag_memo;
@property (nonatomic, retain) NSMutableDictionary *viewClass_memo;
@property (nonatomic, retain) NSMutableDictionary *viewId_memo;
@property (nonatomic, retain) NSMutableDictionary *viewTag_memo;
@property (nonatomic, retain) NSMutableDictionary *attrList_memo;
@property (nonatomic, retain) NSMutableDictionary *attr_memo;
@property (nonatomic, retain) NSMutableDictionary *attrName_memo;
@property (nonatomic, retain) NSMutableDictionary *attrValue_memo;
@property (nonatomic, retain) NSMutableDictionary *variableBindingValue_memo;
@property (nonatomic, retain) NSMutableDictionary *quotedStringValue_memo;
@property (nonatomic, retain) NSMutableDictionary *newline_memo;
@property (nonatomic, retain) NSMutableDictionary *viewPrimitives_memo;
@end

@implementation TemplateParser

- (id)initWithDelegate:(id)d {
    self = [super initWithDelegate:d];
    if (self) {
        self.startRuleName = @"template";
        self.tokenKindTab[@"#"] = @(TEMPLATEPARSER_TOKEN_KIND_POUND);
        self.tokenKindTab[@"NEWLINE"] = @(TEMPLATEPARSER_TOKEN_KIND_NEWLINE);
        self.tokenKindTab[@"Button"] = @(TEMPLATEPARSER_TOKEN_KIND_BUTTON);
        self.tokenKindTab[@","] = @(TEMPLATEPARSER_TOKEN_KIND_COMMA);
        self.tokenKindTab[@"Label"] = @(TEMPLATEPARSER_TOKEN_KIND_LABEL);
        self.tokenKindTab[@"ImageView"] = @(TEMPLATEPARSER_TOKEN_KIND_IMAGEVIEW);
        self.tokenKindTab[@"INDENT"] = @(TEMPLATEPARSER_TOKEN_KIND_INDENT);
        self.tokenKindTab[@"="] = @(TEMPLATEPARSER_TOKEN_KIND_EQUALS);
        self.tokenKindTab[@"{"] = @(TEMPLATEPARSER_TOKEN_KIND_OPEN_CURLY);
        self.tokenKindTab[@"DEDENT"] = @(TEMPLATEPARSER_TOKEN_KIND_DEDENT);
        self.tokenKindTab[@"."] = @(TEMPLATEPARSER_TOKEN_KIND_DOT);
        self.tokenKindTab[@"TextField"] = @(TEMPLATEPARSER_TOKEN_KIND_TEXTFIELD);
        self.tokenKindTab[@"("] = @(TEMPLATEPARSER_TOKEN_KIND_OPEN_PAREN);
        self.tokenKindTab[@"}"] = @(TEMPLATEPARSER_TOKEN_KIND_CLOSE_CURLY);
        self.tokenKindTab[@")"] = @(TEMPLATEPARSER_TOKEN_KIND_CLOSE_PAREN);
        self.tokenKindTab[@"TextView"] = @(TEMPLATEPARSER_TOKEN_KIND_TEXTVIEW);

        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_POUND] = @"#";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_NEWLINE] = @"NEWLINE";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_BUTTON] = @"Button";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_COMMA] = @",";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_LABEL] = @"Label";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_IMAGEVIEW] = @"ImageView";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_INDENT] = @"INDENT";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_EQUALS] = @"=";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_OPEN_CURLY] = @"{";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_DEDENT] = @"DEDENT";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_DOT] = @".";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_TEXTFIELD] = @"TextField";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_OPEN_PAREN] = @"(";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_CLOSE_CURLY] = @"}";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_CLOSE_PAREN] = @")";
        self.tokenKindNameTab[TEMPLATEPARSER_TOKEN_KIND_TEXTVIEW] = @"TextView";

        self.template_memo = [NSMutableDictionary dictionary];
        self.expression_memo = [NSMutableDictionary dictionary];
        self.line_memo = [NSMutableDictionary dictionary];
        self.subBlock_memo = [NSMutableDictionary dictionary];
        self.indent_memo = [NSMutableDictionary dictionary];
        self.dedent_memo = [NSMutableDictionary dictionary];
        self.element_memo = [NSMutableDictionary dictionary];
        self.viewElement_memo = [NSMutableDictionary dictionary];
        self.tag_memo = [NSMutableDictionary dictionary];
        self.viewClass_memo = [NSMutableDictionary dictionary];
        self.viewId_memo = [NSMutableDictionary dictionary];
        self.viewTag_memo = [NSMutableDictionary dictionary];
        self.attrList_memo = [NSMutableDictionary dictionary];
        self.attr_memo = [NSMutableDictionary dictionary];
        self.attrName_memo = [NSMutableDictionary dictionary];
        self.attrValue_memo = [NSMutableDictionary dictionary];
        self.variableBindingValue_memo = [NSMutableDictionary dictionary];
        self.quotedStringValue_memo = [NSMutableDictionary dictionary];
        self.newline_memo = [NSMutableDictionary dictionary];
        self.viewPrimitives_memo = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)_clearMemo {
    [_template_memo removeAllObjects];
    [_expression_memo removeAllObjects];
    [_line_memo removeAllObjects];
    [_subBlock_memo removeAllObjects];
    [_indent_memo removeAllObjects];
    [_dedent_memo removeAllObjects];
    [_element_memo removeAllObjects];
    [_viewElement_memo removeAllObjects];
    [_tag_memo removeAllObjects];
    [_viewClass_memo removeAllObjects];
    [_viewId_memo removeAllObjects];
    [_viewTag_memo removeAllObjects];
    [_attrList_memo removeAllObjects];
    [_attr_memo removeAllObjects];
    [_attrName_memo removeAllObjects];
    [_attrValue_memo removeAllObjects];
    [_variableBindingValue_memo removeAllObjects];
    [_quotedStringValue_memo removeAllObjects];
    [_newline_memo removeAllObjects];
    [_viewPrimitives_memo removeAllObjects];
}

- (void)start {
    [self template_]; 
    [self matchEOF:YES]; 
}

- (void)__template {
    
    [self execute:(id)^{
    
  PEG_PUSH_FENCE(@"template");
  return nil;

    }];
    while ([self speculate:^{ [self newline_]; }]) {
        [self newline_]; 
    }
    if ([self speculate:^{ [self expression_]; }]) {
        [self expression_]; 
    }
    while ([self speculate:^{ do {[self newline_]; } while ([self speculate:^{ [self newline_]; }]);[self expression_]; }]) {
        do {
            [self newline_]; 
        } while ([self speculate:^{ [self newline_]; }]);
        [self expression_]; 
    }
    do {
        [self newline_]; 
    } while ([self speculate:^{ [self newline_]; }]);
    [self execute:(id)^{
    
  NSArray* expressions = PEG_REVERSE_ABOVE(PEG_FENCE(@"template"));
  POP(); // pop fence
  PEG_PUSH_TAG(@"template", expressions);
  return nil;

    }];

    [self fireDelegateSelector:@selector(parser:didMatchTemplate:)];
}

- (void)template_ {
    [self parseRule:@selector(__template) withMemo:_template_memo];
}

- (void)__expression {
    
    [self line_]; 
    if ([self speculate:^{ do {[self newline_]; } while ([self speculate:^{ [self newline_]; }]);[self subBlock_]; }]) {
        do {
            [self newline_]; 
        } while ([self speculate:^{ [self newline_]; }]);
        [self subBlock_]; 
    }

    [self fireDelegateSelector:@selector(parser:didMatchExpression:)];
}

- (void)expression_ {
    [self parseRule:@selector(__expression) withMemo:_expression_memo];
}

- (void)__line {
    
    [self element_]; 

    [self fireDelegateSelector:@selector(parser:didMatchLine:)];
}

- (void)line_ {
    [self parseRule:@selector(__line) withMemo:_line_memo];
}

- (void)__subBlock {
    
    [self indent_]; 
    do {
        [self newline_]; 
    } while ([self speculate:^{ [self newline_]; }]);
    while ([self speculate:^{ [self expression_]; do {[self newline_]; } while ([self speculate:^{ [self newline_]; }]);}]) {
        [self expression_]; 
        do {
            [self newline_]; 
        } while ([self speculate:^{ [self newline_]; }]);
    }
    [self dedent_]; 
    [self execute:(id)^{
    
  NSArray* subBlock = PEG_REVERSE_ABOVE(PEG_FENCE(@"subBlock"));
  POP();
  NSMutableDictionary* element = [POP() mutableCopy];
  element[@"subBlock"] = subBlock;
  PUSH([element copy]);
  //PEG_PUSH_TAG(@"subBlock", subBlock);
  return nil;

    }];

    [self fireDelegateSelector:@selector(parser:didMatchSubBlock:)];
}

- (void)subBlock_ {
    [self parseRule:@selector(__subBlock) withMemo:_subBlock_memo];
}

- (void)__indent {
    
    [self match:TEMPLATEPARSER_TOKEN_KIND_OPEN_CURLY discard:YES]; 
    [self match:TEMPLATEPARSER_TOKEN_KIND_INDENT discard:YES]; 
    [self match:TEMPLATEPARSER_TOKEN_KIND_CLOSE_CURLY discard:YES]; 
    [self execute:(id)^{
    
  PEG_PUSH_FENCE(@"subBlock");
  return nil;

    }];

    [self fireDelegateSelector:@selector(parser:didMatchIndent:)];
}

- (void)indent_ {
    [self parseRule:@selector(__indent) withMemo:_indent_memo];
}

- (void)__dedent {
    
    [self match:TEMPLATEPARSER_TOKEN_KIND_OPEN_CURLY discard:YES]; 
    [self match:TEMPLATEPARSER_TOKEN_KIND_DEDENT discard:YES]; 
    [self match:TEMPLATEPARSER_TOKEN_KIND_CLOSE_CURLY discard:YES]; 

    [self fireDelegateSelector:@selector(parser:didMatchDedent:)];
}

- (void)dedent_ {
    [self parseRule:@selector(__dedent) withMemo:_dedent_memo];
}

- (void)__element {
    
    [self viewElement_]; 

    [self fireDelegateSelector:@selector(parser:didMatchElement:)];
}

- (void)element_ {
    [self parseRule:@selector(__element) withMemo:_element_memo];
}

- (void)__viewElement {
    
    [self execute:(id)^{
    
  PEG_PUSH_FENCE(@"viewElement");
  return nil;

    }];
    do {
        [self tag_]; 
    } while ([self speculate:^{ [self tag_]; }]);
    if ([self speculate:^{ [self attrList_]; }]) {
        [self attrList_]; 
    }
    [self execute:(id)^{
    
  NSArray* tags = PEG_REVERSE_ABOVE(PEG_FENCE(@"viewElement"));
  POP();
  PEG_PUSH_TAG(@"viewElement", tags);
  return nil;

    }];

    [self fireDelegateSelector:@selector(parser:didMatchViewElement:)];
}

- (void)viewElement_ {
    [self parseRule:@selector(__viewElement) withMemo:_viewElement_memo];
}

- (void)__tag {
    
    if ([self predicts:TEMPLATEPARSER_TOKEN_KIND_BUTTON, TEMPLATEPARSER_TOKEN_KIND_IMAGEVIEW, TEMPLATEPARSER_TOKEN_KIND_LABEL, TEMPLATEPARSER_TOKEN_KIND_TEXTFIELD, TEMPLATEPARSER_TOKEN_KIND_TEXTVIEW, 0]) {
        [self viewTag_]; 
    } else if ([self predicts:TEMPLATEPARSER_TOKEN_KIND_DOT, 0]) {
        [self viewClass_]; 
    } else if ([self predicts:TEMPLATEPARSER_TOKEN_KIND_POUND, 0]) {
        [self viewId_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'tag'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchTag:)];
}

- (void)tag_ {
    [self parseRule:@selector(__tag) withMemo:_tag_memo];
}

- (void)__viewClass {
    
    [self match:TEMPLATEPARSER_TOKEN_KIND_DOT discard:YES]; 
    [self matchWord:NO]; 
    [self execute:(id)^{
    
  PEG_PUSH_TAG(@"viewClass", POP_STR());
  return nil;

    }];

    [self fireDelegateSelector:@selector(parser:didMatchViewClass:)];
}

- (void)viewClass_ {
    [self parseRule:@selector(__viewClass) withMemo:_viewClass_memo];
}

- (void)__viewId {
    
    [self match:TEMPLATEPARSER_TOKEN_KIND_POUND discard:YES]; 
    [self matchWord:NO]; 
    [self execute:(id)^{
    
  PEG_PUSH_TAG(@"viewId", POP_STR());
  return nil;

    }];

    [self fireDelegateSelector:@selector(parser:didMatchViewId:)];
}

- (void)viewId_ {
    [self parseRule:@selector(__viewId) withMemo:_viewId_memo];
}

- (void)__viewTag {
    
    [self viewPrimitives_]; 
    [self execute:(id)^{
    
  PEG_PUSH_TAG(@"viewTag", POP_STR());
  return nil;

    }];

    [self fireDelegateSelector:@selector(parser:didMatchViewTag:)];
}

- (void)viewTag_ {
    [self parseRule:@selector(__viewTag) withMemo:_viewTag_memo];
}

- (void)__attrList {
    
    [self execute:(id)^{
    
  PEG_PUSH_FENCE(@"attrList");
  return nil;

    }];
    [self match:TEMPLATEPARSER_TOKEN_KIND_OPEN_PAREN discard:YES]; 
    do {
        [self attr_]; 
    } while ([self speculate:^{ [self attr_]; }]);
    [self match:TEMPLATEPARSER_TOKEN_KIND_CLOSE_PAREN discard:YES]; 
    [self execute:(id)^{
    
  NSArray* attrs = PEG_REVERSE_ABOVE(PEG_FENCE(@"attrList"));
  POP(); // pop fence
  PEG_PUSH_TAG(@"attrList", attrs);
  return nil;

    }];

    [self fireDelegateSelector:@selector(parser:didMatchAttrList:)];
}

- (void)attrList_ {
    [self parseRule:@selector(__attrList) withMemo:_attrList_memo];
}

- (void)__attr {
    
    [self attrName_]; 
    [self match:TEMPLATEPARSER_TOKEN_KIND_EQUALS discard:YES]; 
    [self attrValue_]; 
    if ([self predicts:TEMPLATEPARSER_TOKEN_KIND_COMMA, 0]) {
        [self match:TEMPLATEPARSER_TOKEN_KIND_COMMA discard:YES]; 
    }
    [self execute:(id)^{
    
  id attrValue = POP();
  NSString* attrName = POP_STR();
  PEG_PUSH_TAG(@"attr", PEG_DICT(@"attrName": attrName, @"attrValue": attrValue));
  return nil;

    }];

    [self fireDelegateSelector:@selector(parser:didMatchAttr:)];
}

- (void)attr_ {
    [self parseRule:@selector(__attr) withMemo:_attr_memo];
}

- (void)__attrName {
    
    [self matchWord:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchAttrName:)];
}

- (void)attrName_ {
    [self parseRule:@selector(__attrName) withMemo:_attrName_memo];
}

- (void)__attrValue {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self variableBindingValue_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self quotedStringValue_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'attrValue'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchAttrValue:)];
}

- (void)attrValue_ {
    [self parseRule:@selector(__attrValue) withMemo:_attrValue_memo];
}

- (void)__variableBindingValue {
    
    [self execute:(id)^{
    
  PEG_PUSH_FENCE(@"variableBindingValue");
  return nil;

    }];
    [self matchWord:NO]; 
    while ([self speculate:^{ [self match:TEMPLATEPARSER_TOKEN_KIND_DOT discard:NO]; [self matchWord:NO]; }]) {
        [self match:TEMPLATEPARSER_TOKEN_KIND_DOT discard:NO]; 
        [self matchWord:NO]; 
    }
    [self execute:(id)^{
    
  NSArray *vals = PEG_REVERSE_ABOVE(PEG_FENCE(@"variableBindingValue"));
  POP(); // pop fence
  PEG_PUSH_TAG(@"variableBindingValue", [vals componentsJoinedByString:@""]);
  return nil;

    }];

    [self fireDelegateSelector:@selector(parser:didMatchVariableBindingValue:)];
}

- (void)variableBindingValue_ {
    [self parseRule:@selector(__variableBindingValue) withMemo:_variableBindingValue_memo];
}

- (void)__quotedStringValue {
    
    [self matchQuotedString:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchQuotedStringValue:)];
}

- (void)quotedStringValue_ {
    [self parseRule:@selector(__quotedStringValue) withMemo:_quotedStringValue_memo];
}

- (void)__newline {
    
    [self match:TEMPLATEPARSER_TOKEN_KIND_OPEN_CURLY discard:YES]; 
    [self match:TEMPLATEPARSER_TOKEN_KIND_NEWLINE discard:YES]; 
    [self match:TEMPLATEPARSER_TOKEN_KIND_CLOSE_CURLY discard:YES]; 

    [self fireDelegateSelector:@selector(parser:didMatchNewline:)];
}

- (void)newline_ {
    [self parseRule:@selector(__newline) withMemo:_newline_memo];
}

- (void)__viewPrimitives {
    
    if ([self predicts:TEMPLATEPARSER_TOKEN_KIND_LABEL, 0]) {
        [self match:TEMPLATEPARSER_TOKEN_KIND_LABEL discard:NO]; 
    } else if ([self predicts:TEMPLATEPARSER_TOKEN_KIND_IMAGEVIEW, 0]) {
        [self match:TEMPLATEPARSER_TOKEN_KIND_IMAGEVIEW discard:NO]; 
    } else if ([self predicts:TEMPLATEPARSER_TOKEN_KIND_TEXTVIEW, 0]) {
        [self match:TEMPLATEPARSER_TOKEN_KIND_TEXTVIEW discard:NO]; 
    } else if ([self predicts:TEMPLATEPARSER_TOKEN_KIND_BUTTON, 0]) {
        [self match:TEMPLATEPARSER_TOKEN_KIND_BUTTON discard:NO]; 
    } else if ([self predicts:TEMPLATEPARSER_TOKEN_KIND_TEXTFIELD, 0]) {
        [self match:TEMPLATEPARSER_TOKEN_KIND_TEXTFIELD discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'viewPrimitives'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchViewPrimitives:)];
}

- (void)viewPrimitives_ {
    [self parseRule:@selector(__viewPrimitives) withMemo:_viewPrimitives_memo];
}

@end
