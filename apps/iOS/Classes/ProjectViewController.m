//
//  ProjectViewController.m
//  Wondew
//
//  Created by Nathan Nichols on 6/30/10.
//  Copyright 2010 InfoLab, Northwestern Univeristy. All rights reserved.
//

#import "ProjectViewController.h"
#import "WondewAppDelegate.h"

@implementation ProjectViewController

-(id) initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:style];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        wondews = [[NSArray alloc] init];
    }
    return self;
}

-(void)setWondews:(NSArray *)newWondews {
    [newWondews retain];
    [wondews release];
    wondews = newWondews;
    [self.tableView reloadData];
}

// Customize the number of sections in the table view.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [wondews count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    cell.textLabel.text = [[wondews objectAtIndex:indexPath.row] objectForKey:@"text"];
    
	// Configure the cell.
    
    return cell;
}

-(void) viewWillDisappear:(BOOL) animated {
    NSLog(@"PVC is cleaing activeProject!");
    [(WondewAppDelegate *)[[UIApplication sharedApplication] delegate] setActiveProject:nil];
    [super viewWillDisappear:animated];
}

@end
