//
//  ThumbsDownloader.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 1/20/12.
//  Copyright 2012 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@protocol ThumbsDownloaderDelegate;

@interface ThumbsDownloader : NSObject<ASIHTTPRequestDelegate> {
    NSMutableDictionary* _photoIds;
}

@property (assign) id<ThumbsDownloaderDelegate> delegate;

@property NSInteger startIndex;
@property NSInteger stopIndex;

@property int albumId;

- (void)startDownload;

@property BOOL isAlbumDownloader;

@end


@protocol ThumbsDownloaderDelegate<NSObject>

- (void)thumbsDownloader:(ThumbsDownloader*)dldr didFinishWithImage:(UIImage*)image atIndex:(NSInteger)index;
- (void)thumbsDownloader:(ThumbsDownloader*)dldr didFailWithError:(NSError*)error;
@end