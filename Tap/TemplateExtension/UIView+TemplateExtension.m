//
//  UIView+TemplateExtension.m
//  
//
//  Created by Rocky Duan on 5/3/14.
//
//

#import "TemplateBuilder.h"
#import "UIView+NUI.h"
#import "UIView+AutoLayout.h"

#import "UIButton+NUI.h"
#import "UILabel+NUI.h"
#import "UITextView+NUI.h"
#import "UITextField+NUI.h"

#import "UIView+TemplateExtension.h"
#import "UITextField+TemplateExtension.h"
#import "UILabel+TemplateExtension.h"
#import "UIView+LayoutExtension.h"
#import <ReactiveCocoa.h>

#import "EXTSynthesize.h"

@implementation UIView (TemplateExtension)

@synthesizeAssociation(UIView, viewModel);
@synthesizeAssociation(UIView, viewId);
@synthesizeAssociation(UIView, templateName);

// just for testing purposes. to be replaced

- (id) initWithTemplate:(NSString *)templateName viewModel:(id<NSObject>)viewModel {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    return [self initWithTemplate:templateName viewModel:viewModel frame:CGRectMake(0, 0, screenWidth, screenHeight)];
}

- (id) initWithTemplate:(NSString*) templateName viewModel:(id<NSObject>)viewModel frame:(CGRect)frame{
    NSString* path = [[NSBundle mainBundle] pathForResource:templateName ofType:@"tpl"];
    NSString* content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    TemplateBuilder *templateBuilder = [[TemplateBuilder alloc] init];
    
    Template *template = [templateBuilder buildTemplateFromString:content];
    
    //NSDictionary *template = [templateEngine parseTemplateFromString:content];
    NSLog(@"now trying to initialize");
    self = [self initWithFrame:frame];
    NSLog(@"inited");
    if (self) {
        self.templateName = templateName;
        self.viewModel = viewModel;
        [template buildView:self withViewModel:viewModel];
        NSLog(@"view initialized!");
        //NSLog(@"parsed template: %@", template);
        //[self buildViewFromTemplate:template];
        NSLog(@"view built!");
        NSLog(@"subviews: %@", self.subviews);
        NSLog(@"viewMap: %@", [self viewMap]);
        [self rerenderLayoutWithName:templateName andViewMap: [self viewMap]];
        //UITextView *primaryTextField = [self viewMap][@"primaryTextField"];
        //UITextView *secondaryTextField = [self viewMap][@"secondaryTextField"];
        //UILabel *displayLabel = [self viewMap][@"displayLabel"];
        //RACChannelTo(self, syncValue) = [primaryTextField rac_newTextChannel];
        //RACChannelTo(self, syncValue) = [secondaryTextField rac_newTextChannel];
        //RACChannelTo(self, syncValue) = RACChannelTo(displayLabel, text);
    }
    return self;
}

- (id) initWithTemplateViewElement:(TemplateViewElement*)templateViewElement viewModel:(NSObject*)viewModel {
    self = [self initForAutoLayout];
    if (self) {
        self.viewId = templateViewElement.viewId;
        self.nuiClass = [templateViewElement.viewClasses componentsJoinedByString:@":"];
    }
    return self;
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

- (void) bindAttributeKeypath:(NSString*) attributeKeypath withViewModel:(NSObject*)viewModel keyPath:(NSString*)viewModelKeypath {
    NSLog(@"attribute keypath: %@", attributeKeypath);
    NSLog(@"view model keypath: %@", viewModelKeypath);
    [[RACKVOChannel alloc] initWithTarget:viewModel keyPath:viewModelKeypath nilValue:nil][@keypath(RACKVOChannel.new, followingTerminal)] =
    [[RACKVOChannel alloc] initWithTarget:self keyPath:attributeKeypath nilValue:nil][@keypath(RACKVOChannel.new, followingTerminal)];
    
}

@end