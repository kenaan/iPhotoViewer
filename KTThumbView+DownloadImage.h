//
//  KTThumbView+DownloadImage.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/28/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "KTThumbView.h"
#import "PhotoDownloadManager.h"

@interface KTThumbView (DownloadImage) <PhotoDownloadManagerDelegate>

- (void)setImageWithDownloadManager:(PhotoDownloadManager *)mgr index:(NSUInteger)index;
- (void)setImageWithDownloadManager:(PhotoDownloadManager *)mgr index:(NSUInteger)index placeholderImage:(UIImage*)placeholder;

@end
