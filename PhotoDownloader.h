//
//  PhotoDownloader.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/28/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@protocol PhotoDownloaderDelegate;

@interface PhotoDownloader : NSObject<ASIHTTPRequestDelegate> {
    UIImage* _image;
    int albumId;
    int photoId;
    ASIHTTPRequest* request;
}

@property NSUInteger index;
@property (assign) id <PhotoDownloaderDelegate> delegate;
@property (retain) UIImage* image;

- (void)startDownload;
- (void)cancelDownload;
- (id)initWithIndex:(NSUInteger)idx;
- (id)initWithAlbum:(int)alId index:(NSUInteger)idx;

@end

@protocol PhotoDownloaderDelegate 

- (void)photoDownloader:(PhotoDownloader*)dldr didFinishWithImage:(UIImage*)image;
- (void)photoDownloader:(PhotoDownloader*)dldr didFailWithError:(NSError*)error;
@end