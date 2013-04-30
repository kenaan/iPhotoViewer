//
//  KTPhotoView+DownloadImage.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/28/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "KTPhotoView+DownloadImage.h"

@implementation KTPhotoView (DownloadImage)

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
        [self setImage:cachedImage];
    }
    else {
        cachedImage = [manager imageAtIndex:index isHiRes:NO];
        if (cachedImage) {
            [self setImage:cachedImage];
        }
        [manager downloadPhotoAtIndex:index delegate:self];
    }
}

- (void)downloadManager:(PhotoDownloadManager *)manager didFinishWithImage:(UIImage *)image key:(NSString*)key {
    [self setImage:image];
    self.imageKey = key;
}


- (void)downloadManager:(PhotoDownloadManager *)manager didFailWithError:(NSError *)error {

}

@end
