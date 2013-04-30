//
//  PhotoDownloadManager.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/28/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoDownloader.h"
#import "ThumbsDownloader.h"

@protocol PhotoDownloadManagerDelegate;
@class Album;

@interface PhotoDownloadManager : NSObject<PhotoDownloaderDelegate, ThumbsDownloaderDelegate> {
    NSMutableArray *downloaders;
    NSMutableArray* delegates;
    NSMutableDictionary *downloaderForIndex;
    ThumbsDownloader *thumbsDownloader;
    NSMutableDictionary* thumbDownloadDelegates;
}

@property int albumId;
@property int count;

- (id)init;
- (id)initWithAlbum:(int)alId;
- (UIImage*)imageAtIndex:(NSUInteger)index isHiRes:(BOOL)isHiRes;
- (void)downloadPhotoAtIndex:(NSUInteger)index delegate:(id<PhotoDownloadManagerDelegate>)delegate;
- (void)cancelForDelegate:(id<PhotoDownloadManagerDelegate>)delegate;

- (void)setDelegate:(id<PhotoDownloadManagerDelegate>)delegate forThumbnailWithIndex:(NSUInteger)index;
- (void)downloadThumbsFromIndex:(NSInteger)startIndex until:(NSInteger)stopIndex;
- (void)startThumbsDownload;
@end

@protocol PhotoDownloadManagerDelegate <NSObject>

@optional

- (void)downloadManager:(PhotoDownloadManager *)manager didFinishWithImage:(UIImage *)image;
- (void)downloadManager:(PhotoDownloadManager *)manager didFinishWithImage:(UIImage *)image key:(NSString*)key;
- (void)downloadManager:(PhotoDownloadManager *)manager didFailWithError:(NSError*)error;

@end
