//
//  AddProjectViewController.h
//  Wondew
//
//  Created by Nathan Nichols on 7/1/10.
//  Copyright 2010 InfoLab, Northwestern Univeristy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddProjectViewController : UIViewController {
    UITextField *projectTextField;
    UITextView *wondewTextView;
}

@property (nonatomic, retain) IBOutlet UITextField *projectTextField;
@property (nonatomic, retain) IBOutlet UITextView *wondewTextView;

-(IBAction)addProject;
-(IBAction)cancel;

@end
