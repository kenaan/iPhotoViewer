//
//  PhotoLibraryDataSource.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/28/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTPhotoBrowserDataSource.h"


@interface PhotoLibraryDataSource : NSObject <KTPhotoBrowserDataSource> {
    NSArray *images;
}

@end
