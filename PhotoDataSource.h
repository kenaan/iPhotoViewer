//
//  PhotoDataSource.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/28/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTPhotoBrowserDataSource.h"

@class Database;
@class PhotoDownloadManager;

@protocol PhotoDelegate

- (void)exportImageAtIndex:(NSUInteger)index photoView:(UIView *)photoView;

@end

@interface PhotoDataSource : NSObject <KTPhotoBrowserDataSource> {
    int _albumId;
    PhotoDownloadManager *downloadManager;
}

@property (assign) id<PhotoDelegate> delegate;

- (void)exportImageAtIndex:(NSInteger)index photoView:(UIView *)photoView;
- (id)initWithAlbum:(int)albumId;
- (UIImage*)imageAtIndex:(NSUInteger)index;

- (void)updateWithDatabase;
@end
