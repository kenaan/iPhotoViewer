//
//  AlbumViewController.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 12/15/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "CollectionViewController.h"

@class Album;

@interface AlbumViewController : CollectionViewController

- (id)initWithAlbum:(int)albumId;

@end
