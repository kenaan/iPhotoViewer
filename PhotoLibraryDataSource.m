//
//  PhotoLibraryDataSource.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/28/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "PhotoLibraryDataSource.h"

@implementation PhotoLibraryDataSource


#pragma mark -
#pragma mark KTPhotoBrowserDataSource

- (NSInteger)numberOfPhotos {
    NSInteger count = [images count];
    return count;
}

- (void)imageAtIndex:(NSInteger)index photoView:(KTPhotoView *)photoView {
    NSArray *imageUrls = [images objectAtIndex:index];
    NSString *url = [imageUrls objectAtIndex:FULL_SIZE_INDEX];
    [photoView  setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];
}

- (void)thumbImageAtIndex:(NSInteger)index thumbView:(KTThumbView *)thumbView {
    NSArray *imageUrls = [images_ objectAtIndex:index];
    NSString *url = [imageUrls objectAtIndex:THUMBNAIL_INDEX];
    [thumbView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"photoDefault.png"]];
}

@end
