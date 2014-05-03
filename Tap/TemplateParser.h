#import <PEGKit/PKParser.h>

enum {
    TEMPLATEPARSER_TOKEN_KIND_POUND = 14,
    TEMPLATEPARSER_TOKEN_KIND_NEWLINE,
    TEMPLATEPARSER_TOKEN_KIND_BUTTON,
    TEMPLATEPARSER_TOKEN_KIND_COMMA,
    TEMPLATEPARSER_TOKEN_KIND_LABEL,
    TEMPLATEPARSER_TOKEN_KIND_IMAGEVIEW,
    TEMPLATEPARSER_TOKEN_KIND_INDENT,
    TEMPLATEPARSER_TOKEN_KIND_EQUALS,
    TEMPLATEPARSER_TOKEN_KIND_OPEN_CURLY,
    TEMPLATEPARSER_TOKEN_KIND_DEDENT,
    TEMPLATEPARSER_TOKEN_KIND_DOT,
    TEMPLATEPARSER_TOKEN_KIND_TEXTFIELD,
    TEMPLATEPARSER_TOKEN_KIND_OPEN_PAREN,
    TEMPLATEPARSER_TOKEN_KIND_CLOSE_CURLY,
    TEMPLATEPARSER_TOKEN_KIND_CLOSE_PAREN,
    TEMPLATEPARSER_TOKEN_KIND_TEXTVIEW,
};

@interface TemplateParser : PKParser

@end

