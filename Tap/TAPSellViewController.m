//
//  TAPSellViewController.m
//  Tap
//
//  Created by Rocky Duan on 4/29/14.
//  Copyright (c) 2014 Tap. All rights reserved.
//

#import "TAPSellViewController.h"
#import "TAPSellViewModel.h"
#import "TemplateExtension/UIView+TemplateExtension.h"
#import <PEGKit/PEGKit.h>
#import <JSONKit.h>


@interface TAPSellViewController ()

@property (strong, nonatomic) TAPSellViewModel *viewModel;

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
    self.viewModel = [[TAPSellViewModel alloc] init];
    self.view = [[UIView alloc] initWithTemplate:@"sell" viewModel:self.viewModel];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
