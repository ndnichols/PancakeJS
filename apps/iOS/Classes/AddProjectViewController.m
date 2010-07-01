//
//  AddProjectViewController.m
//  Wondew
//
//  Created by Nathan Nichols on 7/1/10.
//  Copyright 2010 InfoLab, Northwestern Univeristy. All rights reserved.
//

#import "AddProjectViewController.h"
#import "WondewAppDelegate.h"

@implementation AddProjectViewController
@synthesize projectTextField, wondewTextView;

-(IBAction)addProject {
    NSString *project = projectTextField.text;
    NSArray *wondews = [[wondewTextView text] componentsSeparatedByString:@"\n"];
    [(WondewAppDelegate *)[[UIApplication sharedApplication] delegate] createProject:project withWondews:wondews];
}

-(void)viewDidAppear:(BOOL)animated {
    [projectTextField setText:@""];
    [wondewTextView setText:@""];
    [projectTextField becomeFirstResponder];
    [super viewDidAppear:animated];
}


- (void)dealloc {
    [super dealloc];
}
@end
