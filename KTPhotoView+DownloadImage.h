//
//  KTPhotoView+DownloadImage.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/28/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "KTPhotoView.h"
#import "PhotoDownloadManager.h"

@interface KTPhotoView (DownloadImage) <PhotoDownloadManagerDelegate>

- (void)setImageWithDownloadManager:(PhotoDownloadManager *)mgr index:(NSUInteger)index;
- (void)setImageWithDownloadManager:(PhotoDownloadManager *)mgr index:(NSUInteger)index placeholderImage:(UIImage*)placeholder;

@end
