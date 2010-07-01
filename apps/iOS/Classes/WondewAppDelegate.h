//
//  WondewAppDelegate.h
//  Wondew
//
//  Created by Nathan Nichols on 6/30/10.
//  Copyright InfoLab, Northwestern Univeristy 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RootViewController.h"
#import "ProjectViewController.h"
#import "AddWondewViewController.h"
#import "AddProjectViewController.h"
#import "LoadingViewController.h"
#import "Pancake.h"

@interface WondewAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    RootViewController *rootViewController;
    ProjectViewController *projectViewController;
    AddWondewViewController *addWondewViewController;
    AddProjectViewController *addProjectViewController;
    LoadingViewController *loadingViewController;
    UINavigationController *navigationController;
    
    NSDictionary *activeProject;
    
    NSMutableArray *projects; //A list of dictionaries, each dict is a project with 'title' and 'wondews' in it
    Pancake *pancake;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;

-(void)projectsDidFinishLoading:(NSArray *)newProjects;
-(void)projectTapped:(NSInteger)index;
-(void)createWondews:(NSArray *)newWondews;
-(void)createProject:(NSString *)projectTitle withWondews:(NSArray *)wondews;
-(void)reloadProjects;
-(void)redrawTables;
-(void)setActiveProject:(NSDictionary *)project;
@end

