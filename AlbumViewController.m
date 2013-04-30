//
//  AlbumViewController.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 12/15/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "AlbumViewController.h"
#import "Client.h"
#import "PhotoDownloader.h"

@implementation AlbumViewController

- (id)initWithAlbum:(int)albumId
{
    if ((self = [super init])) {
        self.images = [[PhotoDataSource alloc] initWithAlbum:albumId];
        self.images.delegate = self;
        [self setDataSource:self.images];
    }
    return self;
}


- (void)dealloc 
{
    [self.images release]; 
    self.images = nil;

    [super dealloc];
}

@end
