//
//  iPhotoViewerAppDelegate.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/8/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import "iPhotoViewerAppDelegate.h"
#import "MasterViewController.h"
#import "LibraryViewController.h"
#import "TwitterAgent.h"
#import "FacebookAgent.h"
#import "SDImageCache.h"

extern TwitterAgent* twitterAgent;
extern FacebookAgent* facebookAgent;

@implementation iPhotoViewerAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;

- (void)dealloc
{
    [twitterAgent release];
    [facebookAgent release];
    [_window release];
    [_navigationController release];
    [_splitViewController release];
    [super dealloc];
}


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application   {
    [[SDImageCache sharedImageCache] clearMemory];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[SDImageCache sharedImageCache] clearDisk];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    MasterViewController *masterViewController = nil;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController_iPhone" bundle:nil] autorelease];
        self.navigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
        self.window.rootViewController = self.navigationController;
    } else {
        masterViewController = [[[MasterViewController alloc] initWithNibName:@"MasterViewController_iPad" bundle:nil] autorelease];
        UINavigationController *masterNavigationController = [[[UINavigationController alloc] initWithRootViewController:masterViewController] autorelease];
      
        LibraryViewController *libController = [[[LibraryViewController alloc] init] autorelease];
        UINavigationController *libNavigationController = [[[UINavigationController alloc] initWithRootViewController:libController] autorelease];

        self.splitViewController = [[[UISplitViewController alloc] init] autorelease];
        self.splitViewController.delegate = libController;
        self.splitViewController.viewControllers = [NSArray arrayWithObjects:masterNavigationController, libNavigationController, nil];
        
        masterViewController.libraryViewController = libController;
        
        self.window.rootViewController = self.splitViewController;
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebookAgent.facebook handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebookAgent.facebook handleOpenURL:url];
}
@end
