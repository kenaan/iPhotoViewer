//
//  PhotoDataSource.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/28/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "PhotoDataSource.h"
#import "Database.h"
#import "Client.h"
#import "PhotoDownloadManager.h"
#import "KTThumbView+DownloadImage.h"
#import "KTPhotoView+DownloadImage.h"

@interface PhotoDataSource()
@property NSInteger photosCount;
@end

@implementation PhotoDataSource

@synthesize delegate, photosCount;

- (id)init {
    if ((self = [super init])) {
        downloadManager = [[PhotoDownloadManager alloc] init];
    }
    return self;
}

- (void)updateWithDatabase {
    self.photosCount = [[Client instance].database.photoIds count];
    downloadManager.count = self.photosCount;
}

- (id)initWithAlbum:(int)albumId {
    if ((self = [super init])) {
        _albumId = albumId;
        downloadManager = [[PhotoDownloadManager alloc] initWithAlbum:albumId];
        NSNumber* album = [NSNumber numberWithInt:_albumId];
        NSMutableArray* albumPhotos = [[Client instance].database.albumPhotoIds objectForKey:album];
        self.photosCount = [albumPhotos count];        
    }
    return self;    
}

- (UIImage*)imageAtIndex:(NSUInteger)index {
    UIImage* ret = [downloadManager imageAtIndex:index isHiRes:YES];
    if (!ret)
        ret = [downloadManager imageAtIndex:index isHiRes:NO];
    return ret;
}

- (void)dealloc {
    [downloadManager release];
    [super dealloc];
}
#pragma mark -
#pragma mark KTPhotoBrowserDataSource

- (NSInteger)numberOfPhotos {
    return self.photosCount;
}


- (void)imageAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView {
    [photoView setImageWithDownloadManager:downloadManager index:index placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}

- (void)thumbImageAtIndex:(NSInteger)index thumbView:(KTThumbView *)thumbView {
    [thumbView setImageWithDownloadManager:downloadManager index:index placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}

- (void)exportImageAtIndex:(NSInteger)index photoView:(UIView *)photoView {
    [self.delegate exportImageAtIndex:index photoView:photoView];
}

- (void)downloadIndicesFrom:(NSInteger)startIndex until:(NSInteger)stopIndex {
    [downloadManager downloadThumbsFromIndex:startIndex until:stopIndex];
}

- (void)startDownload {
    [downloadManager startThumbsDownload];
}

@end
