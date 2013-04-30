//
//  LibraryViewController.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/20/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollectionViewController.h"
#import "Client.h"
#import "Database.h"

@interface LibraryViewController : CollectionViewController<UISplitViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, ClientDelegate, DatabaseDelegate>
{
    UIPopoverController *_masterPopoverController;
    UITableView* albumsView;
    
    Client* client;
}

- (id)initWithLibrary:(NSString*)host port:(NSInteger)port;
- (void)connectToLibrary:(NSString*)host port:(NSInteger)port;
- (void)updateView;
@end



