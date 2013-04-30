//
//  KTThumbView+DownloadImage.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/28/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "KTThumbView+DownloadImage.h"
#import "Client.h"

@implementation KTThumbView (DownloadImage)

- (void)setImageWithDownloadManager:(PhotoDownloadManager *)mgr index:(NSUInteger)index
{
    [self setImageWithDownloadManager:mgr index:index placeholderImage:nil];
}

- (void)setImageWithDownloadManager:(PhotoDownloadManager *)manager index:(NSUInteger)index placeholderImage:(UIImage *)placeholder 
{
    // Remove in progress downloader from queue
    [manager cancelForDelegate:self];

    UIImage *cachedImage = [manager imageAtIndex:index isHiRes:YES];
    if (cachedImage) {
        [self setThumbImage:cachedImage];
    }
    else {
        cachedImage = [manager imageAtIndex:index isHiRes:NO];
        if (cachedImage) {
            [self setThumbImage:cachedImage];
        } else {
            [self setThumbImage:placeholder];
          }
        [manager setDelegate:self forThumbnailWithIndex:index];
    }
}

- (void)downloadManager:(PhotoDownloadManager *)manager didFinishWithImage:(UIImage *)image
{
    [self setThumbImage:image];
}

- (void)downloadManager:(PhotoDownloadManager *)manager didFailWithError:(NSError *)error {
}

@end
