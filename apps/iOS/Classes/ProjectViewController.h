//
//  ProjectViewController.h
//  Wondew
//
//  Created by Nathan Nichols on 6/30/10.
//  Copyright 2010 InfoLab, Northwestern Univeristy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectViewController : UITableViewController {
    NSArray *wondews;
}

-(void)setWondews:(NSArray *)wondews;

@end
