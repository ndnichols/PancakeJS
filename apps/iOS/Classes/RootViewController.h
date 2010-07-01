//
//  RootViewController.h
//  Wondew
//
//  Created by Nathan Nichols on 6/30/10.
//  Copyright InfoLab, Northwestern Univeristy 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UITableViewController {
    @private
    NSArray *projectTitles; //A list of strings, each a project title
    
}

-(void)setProjectTitles:(NSArray *)newProjectTitles;

@end
