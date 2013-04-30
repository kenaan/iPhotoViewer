//
//  PhotoManager.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/28/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PhotoDownloader.h"

@class Database;
@protocol PhotoManagerDelegate;

@interface PhotoManager : NSObject <PhotoDownloaderDelegate>
{
    NSMutableArray *delegates;
    NSMutableArray *downloaders;
}

+ (id)sharedManager;
- (UIImage *)imageWithURL:(NSURL *)url;
- (void)downloadWithDatabase:(Database *)db atIndex:(int)index delegate:(id<PhotoManagerDelegate>)delegate;
- (void)cancelForDelegate:(id<PhotoManagerDelegate>)delegate;

@end


@protocol PhotoManagerDelegate <NSObject>

@optional

- (void)photoManager:(PhotoManager *)imageManager didFinishWithImage:(UIImage *)image;

@end