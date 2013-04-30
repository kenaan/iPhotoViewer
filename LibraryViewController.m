//
//  LibraryViewController.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/20/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "LibraryViewController.h"
#import "Database.h"
#import "PhotoDownloader.h"
#import "AlbumViewController.h"
#import "BusyView.h"
#import "Globals.h"

#define kLibraryViewType @"LibraryViewType"

typedef enum {
    kViewAlbums = 0,
    kViewPhotos = 1
} TViewType;

@interface LibraryViewController ()

- (void)addObservers;
- (void)removeObservers;

@property TViewType viewType;
@property (assign) KTThumbsView* thumbsView;
@property (retain, nonatomic) UIPopoverController *masterPopoverController;
@property (assign) BusyView* busyView;
@end

@implementation LibraryViewController

@synthesize selectedPhotoIndex, viewType;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize thumbsView;
@synthesize busyView;


- (id)initWithLibrary:(NSString *)host port:(NSInteger)port {
    if ((self = [super init])) {
        
        [self addObservers];

        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.viewType = [defaults integerForKey:kLibraryViewType];
        [defaults synchronize];
        [self connectToLibrary:host port:port];
    }
    return self;
}

- (void)cleanup {
    [self.images release]; 
    self.images = nil;
    
    [client disconnect]; 
    [client release]; 
    client = nil;
}

- (void)connectToLibrary:(NSString*)host port:(NSInteger)port {
    [self cleanup];

    self.images = [[PhotoDataSource alloc] init];

    client = [[Client alloc] initWithHost:host port:port];
    client.delegate = self;

    [self performSelectorInBackground:@selector(connectOnBackground) withObject:nil];
}

- (void)connectOnBackground {
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [client connect];
    [pool release];
}


- (void)dealloc 
{
    [self cleanup];
    [self removeObservers];
    [_masterPopoverController release];
    [super dealloc];
}

- (void)viewDidLoad 
{
	NSArray *segmentTextContent = [NSArray arrayWithObjects:
                                   NSLocalizedString(@"Albums", @""),
                                   NSLocalizedString(@"Photos", @""),
								   nil];
	UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
	segmentedControl.selectedSegmentIndex = 0;
	segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.frame = CGRectMake(0, 0, 200, 30.0);
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	
	// defaultTintColor = [segmentedControl.tintColor retain];	// keep track of this for later
    
//	self.navigationItem.titleView = segmentedControl;
//	[segmentedControl release];
    
    UIBarButtonItem *segmentBarItem = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
    [segmentedControl release];
    
	self.navigationItem.rightBarButtonItem = segmentBarItem;
    [segmentBarItem release];
    
    albumsView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStylePlain];
    albumsView.delegate = self;
    albumsView.dataSource = self;
    albumsView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    albumsView.autoresizesSubviews = YES;
    
    self.thumbsView = (KTThumbsView*)self.view;
//    
//
//    if (!self.isConnected)
//        [self showActivityIndicator];
}

- (void)viewTypeUpdated {
    if (self.viewType == kViewAlbums) {
        self.view = albumsView;
    } else {
        self.view = self.thumbsView;
    }
}

- (void)updateView {
    [albumsView reloadData];
    [self viewTypeUpdated];
}

- (IBAction)segmentAction:(id)sender
{
	// The segmented control was clicked, handle it here 
	UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    self.viewType = segmentedControl.selectedSegmentIndex;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:self.viewType forKey:kLibraryViewType];
    [defaults synchronize];
    [self viewTypeUpdated];

}

- (void)viewWillAppear:(BOOL)animated {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)self.navigationItem.rightBarButtonItem.customView;
    segmentedControl.selectedSegmentIndex = self.viewType;
    [self viewTypeUpdated];
}

- (void)didSelectThumbAtIndex:(NSUInteger)index {
    if (self.viewType == kViewPhotos) {
        [super didSelectThumbAtIndex:index];
    }
}


 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
     return YES;
 }
 

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

#pragma mark - 
#pragma mark Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Libraries", @"Libraries");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark -
#pragma mark TableView (Albums)

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int ret = [client.database.albums count];
    NSLog(@"Number of albums: %d", ret);
    return ret;
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *AlbumCellId = @"AlbumCell";
    
    // Create a new TemperatureCell if necessary
    UITableViewCell *cell =  [albumsView dequeueReusableCellWithIdentifier:AlbumCellId];
    if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AlbumCellId] autorelease];
	}
    
    NSNumber* album = [client.database.albums objectAtIndex:indexPath.row];
    cell.textLabel.text = [client.database.albumNames objectForKey:album]; 
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSNumber* album = [client.database.albums objectAtIndex:indexPath.row];
    AlbumViewController* albumViewController = [[AlbumViewController alloc] initWithAlbum:[album intValue]];
    [self.navigationController pushViewController:albumViewController animated:YES];
    [albumViewController release];
}

#pragma mark -
#pragma mark Client delegate
- (void)clientDidStartConnect:(Client *)client {
    dispatch_async(dispatch_get_main_queue(), ^{
        albumsView.dataSource = self;
        self.busyView = [[[BusyView alloc] initWithTitle:@"Connecting" message:@"Please wait..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil] autorelease];
        [self.busyView show];        
        
    });
}

- (void)clientDidFinishConnect:(Client*)client {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.busyView close];
    });

}

- (void)clientConnected:(Client *)client {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.images updateWithDatabase];
        self.images.delegate = self;
        [self setDataSource:self.images];
        [self updateView];
    });
}

- (void)client:(Client *)client databaseAdded:(Database *)database {
    database.delegate = self;
}

- (void)clientDisconnected:(Client *)client {
    dispatch_async(dispatch_get_main_queue(), ^{
        //albumsView.dataSource = nil;
        [self setDataSource:nil];
        [self reloadThumbs];
        [albumsView reloadData];
    });
}
#pragma mark -
#pragma mark Database delegate

- (void)database:(Database *)database albumAddedAtIndex:(NSInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNumber* album = [client.database.albums objectAtIndex:index];
        NSString* albumName = [client.database.albumNames objectForKey:album];
        [self.busyView setMessage:[NSString stringWithFormat:@"Added album %@", albumName]];
//        [albumsView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    });
}

- (void)database:(Database *)database albumRemovedAtIndex:(NSInteger)index {
    dispatch_async(dispatch_get_main_queue(), ^{
        [albumsView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    });
}

- (void)database:(Database*)database photosAddedForAlbum:(NSNumber *)album {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* albumName = [client.database.albumNames objectForKey:album];
        [self.busyView setMessage:[NSString stringWithFormat:@"Loaded album %@", albumName]];
    });    
}


#pragma mark -
#pragma mark Notifications

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionErrorOccurred:)
                                                 name:kConnectErrorNotification object:nil];
    
}

- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kConnectErrorNotification object:nil];
}

- (void)connectionErrorOccurred:(NSError*)error {
    UIAlertView* connectErrorDlg = [[[UIAlertView alloc] initWithTitle:@"Connection error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
    [connectErrorDlg show];
    [self cleanup];
}

@end
