//
//  AddWondewViewController.h
//  Wondew
//
//  Created by Nathan Nichols on 6/30/10.
//  Copyright 2010 InfoLab, Northwestern Univeristy. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddWondewViewController : UIViewController {
    UITextView *wondewTextView;
    NSString *currProjectTitle;
    UILabel *currProjectLabel;
}

@property (nonatomic, retain) IBOutlet UITextView *wondewTextView;
@property (nonatomic, retain) IBOutlet UILabel *currProjectLabel;
@property (nonatomic, retain) NSString *currProjectTitle;

-(IBAction)addWondews;
-(IBAction)cancel;
-(void)setProjectTitle:(NSString *)projectTitle;

@end
