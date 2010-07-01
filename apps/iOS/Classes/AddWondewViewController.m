//
//  AddWondewViewController.m
//  Wondew
//
//  Created by Nathan Nichols on 6/30/10.
//  Copyright 2010 InfoLab, Northwestern Univeristy. All rights reserved.
//

#import "AddWondewViewController.h"
#import "WondewAppDelegate.h"

@implementation AddWondewViewController

@synthesize wondewTextView;

-(IBAction)addWondews {
    NSArray *wondews = [[wondewTextView text] componentsSeparatedByString:@"\n"];
    [(WondewAppDelegate *)[[UIApplication sharedApplication] delegate] createWondews:wondews];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidAppear:(BOOL)animated {
    NSLog(@"Becoming first responder!");
//    [wondewTextField setEditable:NO];
//    [wondewTextField setEditable:YES];
    [wondewTextView setText:@""];
    [wondewTextView becomeFirstResponder];
    [super viewDidAppear:animated];
}


- (void)dealloc {
    [super dealloc];
}


@end
