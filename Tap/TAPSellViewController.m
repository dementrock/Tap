//
//  TAPSellViewController.m
//  Tap
//
//  Created by Rocky Duan on 4/29/14.
//  Copyright (c) 2014 Tap. All rights reserved.
//

#import "TAPSellViewController.h"
#import "TAPSellView.h"
#import "TemplateParser.h"
#import "TemplateEngine.h"
#import <PEGKit/PEGKit.h>
#import <JSONKit.h>


@interface TAPSellViewController ()
@end


@implementation TAPSellViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView {
    self.view = (TAPSellView*) [self createFullScreenViewWithClass:[TAPSellView class]];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    TemplateParser *parser = [[TemplateParser alloc] init];
    
    //NSString* content = @"Button.sell#haha\n";
    
    //NSString* content = @"Button.sell#haha\n  Button\n";
    
    
    NSString* content = [NSString stringWithContentsOfFile:@"/Users/dementrock/coding/Tap/Tap/sell.tpl" encoding:NSUTF8StringEncoding error:nil];
    
    NSLog(@"content:\n%@", content);
    
    TemplateEngine *templateEngine = [[TemplateEngine alloc] init];
    NSString* preparsedContent = [templateEngine preParseFromString:content];
    
    NSLog(@"preparsed content:\n%@", preparsedContent);
    
    PKAssembly *result = [parser parseString:preparsedContent error:nil];
    NSArray *stack = [result objectsAbove:nil];
    NSLog(@"stack: %@", stack);
    NSLog(@"stack json: %@", [stack JSONStringWithOptions:JKSerializeOptionPretty error:nil]);
    NSLog(@"stack size: %d", stack.count);
    
    //NSLog(@"result: %@", result);
    
    

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

@end
