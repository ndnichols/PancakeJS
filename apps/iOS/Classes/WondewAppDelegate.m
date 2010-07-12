//
//  WondewAppDelegate.m
//  Wondew
//
//  Created by Nathan Nichols on 6/30/10.
//  Copyright InfoLab, Northwestern Univeristy 2010. All rights reserved.
//

#import "WondewAppDelegate.h"
#import "RootViewController.h"


@implementation WondewAppDelegate

@synthesize window;
@synthesize navigationController;

#pragma mark -
#pragma mark Application lifecycle

-(void)projectsDidFinishLoading:(NSArray *)newProjects {
    [navigationController dismissModalViewControllerAnimated:NO];
    BOOL skipToToday = NO;
    if ([projects count] == 0) {
        skipToToday = YES;
    }
    
    [projects autorelease];
    projects = [[NSMutableArray alloc] initWithArray:newProjects];

    [self redrawTables];
    
    if ((skipToToday) && ([projects count])) {
        [self projectTapped:0];
    }
}

-(void)setActiveProject:(NSDictionary *)project {
    activeProject = project;
}

-(void) redrawTables {
    NSMutableArray *projectTitles = [NSMutableArray array];
    for (NSDictionary *project in projects) {
        [projectTitles addObject: [project objectForKey:@"projectTitle"]];
    }
    [rootViewController setProjectTitles:projectTitles];
    if (activeProject) {//we're showing a project, let's redraw it too 
        projectViewController.title = [activeProject objectForKey:@"projectTitle"];
        [projectViewController setWondews:[activeProject objectForKey:@"wondews"]];
        NSLog(@"in rT, just called setWondes on %@", [activeProject objectForKey:@"projectTitle"]);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    activeProject = nil;
    rootViewController = [[RootViewController alloc] initWithStyle:UITableViewStylePlain];
    rootViewController.title = @"Projects";
    rootViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProjectTapped)];
    rootViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadProjects)];
    projectViewController = [[ProjectViewController alloc] initWithStyle:UITableViewStylePlain];
    projectViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addWondewTapped)];
    addWondewViewController = [[AddWondewViewController alloc] initWithNibName:@"AddWondewViewController" bundle:nil];
    addProjectViewController = [[AddProjectViewController alloc] initWithNibName:@"AddProjectViewController" bundle:nil];
    loadingViewController = [[LoadingViewController alloc] initWithNibName:@"LoadingViewController" bundle:nil];
    navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];

    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    pancake = [[Pancake alloc] init];
    [self reloadProjects];
    return YES;
}

-(void)projectTapped:(NSInteger)index {
    NSDictionary *project = [projects objectAtIndex:index];
    [self setActiveProject:project];
    projectViewController.title = [project objectForKey:@"projectTitle"];
    [projectViewController setWondews:[project objectForKey:@"wondews"]];
    [navigationController pushViewController:projectViewController animated:YES];
}

-(void)reloadProjects {
    [navigationController presentModalViewController:loadingViewController animated:NO];
    [pancake load];
}

-(void)addWondewTapped {
    [addWondewViewController setProjectTitle: [activeProject objectForKey:@"projectTitle"]];
    [navigationController presentModalViewController:addWondewViewController animated:YES];
}

-(void)addProjectTapped {
    [navigationController presentModalViewController:addProjectViewController animated:YES];
}

-(void)createWondews:(NSArray *)newWondews {
    if (newWondews) {
        NSString *projectTitle = navigationController.topViewController.title;
        NSMutableDictionary *project;
        for (NSMutableDictionary *temp in projects) {
            if ([[temp objectForKey:@"projectTitle"] isEqualToString:projectTitle]) {
                project = temp;
                break;
            }
        }
        [self setActiveProject:project]; //We lose this when the modal thing comes up, don't ask
        for (NSString *wondew in newWondews) {
            [pancake addWondew:wondew inProject:projectTitle];
            NSDictionary *fullWondew = [NSDictionary dictionaryWithObjectsAndKeys:wondew, @"text", nil]; //Not really full, maybe later if it matters
            [[project objectForKey:@"wondews"] addObject:fullWondew];
        }
    }
    [self redrawTables];
    [navigationController dismissModalViewControllerAnimated:YES];
}

-(void)createProject:(NSString *)projectTitle withWondews:(NSArray *)newWondews {
    NSDictionary *project = [NSDictionary dictionaryWithObjectsAndKeys:projectTitle, @"projectTitle", [NSMutableArray array], @"wondews", nil];
    for (NSString *wondew in newWondews) {
        [pancake addWondew:wondew inProject:projectTitle];
        NSDictionary *fullWondew = [NSDictionary dictionaryWithObjectsAndKeys:wondew, @"text", nil]; //Not really full, maybe later if it matters
        [[project objectForKey:@"wondews"] addObject:fullWondew];
    }
    activeProject = project;
    if ([projects count] > 2) {
        [projects insertObject:project atIndex:1]; //put it near the top since it's new, can rearrange in TM
    }
    else {
        [projects addObject:project];
    }
    [navigationController dismissModalViewControllerAnimated:YES];

    [self redrawTables];
    [navigationController pushViewController:projectViewController animated:YES];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
    NSLog(@"Going away!");
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
    [self reloadProjects];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    NSLog(@"Coming back!");
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}


@end

