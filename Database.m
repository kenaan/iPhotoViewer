//
//  Database.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/17/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import "Database.h"

@implementation Database

@synthesize dbId, albums = _albums, photoIds = _photoIds, albumNames = _albumNames, albumPhotoIds = _albumPhotoIds, photos = _photos, delegate;

- (void)dealloc {
    [_photos release];
    _photos = nil;
    [_photoIds release];
    _photoIds = nil;
    [_albums release];
    _albums = nil;
    [_albumPhotoIds release];
    _albumPhotoIds = nil;
    [_albumNames release];
    _albumNames = nil;
    [super dealloc];
}

- (id)init {
    if ((self = [super init])) {
        _photoIds = [[NSMutableArray alloc] init];
        _albums = [[NSMutableArray alloc] init];
        _albumNames = [[NSMutableDictionary alloc] init];
        _albumPhotoIds = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addAlbum:(int)albumId name:(NSString*)albumName {
    NSNumber* album = [NSNumber numberWithInt:albumId];
    if (NO == [self.albums containsObject:album]) {
        //NSLog(@"Adding album: %@ id: %d", albumName, albumId);
        [self.albums addObject:album];
        [self.albumNames setObject:albumName forKey:album];
        [self.delegate database:self albumAddedAtIndex:[self.albums indexOfObject:album]];
    }
}

- (void)addPhotoIds:(NSMutableArray *)photoIds forAlbum:(NSNumber *)album {
    [self.albumPhotoIds setObject:photoIds forKey:album];
    [self.delegate database:self photosAddedForAlbum:album];
}
@end
