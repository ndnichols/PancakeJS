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

@synthesize wondewTextView, currProjectLabel, currProjectTitle;

-(IBAction)addWondews {
    NSArray *wondews = [[wondewTextView text] componentsSeparatedByString:@"\n"];
    [(WondewAppDelegate *)[[UIApplication sharedApplication] delegate] createWondews:wondews];
}

-(IBAction)cancel {
    NSLog(@"Cancelling");
    [(WondewAppDelegate *)[[UIApplication sharedApplication] delegate] createWondews:[NSArray array]];
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

-(void) setProjectTitle: (NSString *)projectTitle {
    self.currProjectTitle = [NSString stringWithFormat:@"%@:", projectTitle];
    currProjectLabel.text = currProjectTitle;
}

-(void)viewWillAppear:(BOOL)animated {
    NSLog(@"Becoming first responder!");
    currProjectLabel.text = currProjectTitle;
    [wondewTextView setText:@""];
    [wondewTextView becomeFirstResponder];
    [super viewDidAppear:animated];
}


- (void)dealloc {
    [super dealloc];
}


@end
