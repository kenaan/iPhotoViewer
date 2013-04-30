//
//  MasterViewController.h
//  testNavigation
//
//  Created by Leon Meerson on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@class LibraryViewController;

@interface MasterViewController : UITableViewController<NSNetServiceBrowserDelegate, NSNetServiceDelegate, FBSessionDelegate> {
@private
	NSMutableArray* _services;
	NSNetServiceBrowser* _netServiceBrowser;
	NSNetService* _currentResolve;
	NSTimer* _timer;
	BOOL _needsActivityIndicator;
	BOOL _initialWaitOver;
}

@property (retain, nonatomic) LibraryViewController *libraryViewController;

@end
