//
//  PhotoManager.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/28/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "PhotoManager.h"

static PhotoManager *instance;

@implementation PhotoManager

- (id)init
{
    if ((self = [super init]))
    {
        delegates = [[NSMutableArray alloc] init];
        downloaders = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [delegates release], delegates = nil;
    [downloaders release], downloaders = nil;
    [super dealloc];
}


+ (id)sharedManager
{
    if (instance == nil)
    {
        instance = [[PhotoManager alloc] init];
    }
    
    return instance;
}


- (void)downloadWithDatabase:(Database *)db atIndex:(int)index delegate:(id<PhotoManagerDelegate>)delegate
{
    if (!db || !delegate)
    {
        return;
    }
    
    PhotoDownloader* 
    if (!downloader)
    {
        downloader = [PhotoDownloader downloaderWithDatabase:db atIndex:index delegate:self];
    }
    
    [delegates addObject:delegate];
    [downloaders addObject:downloader];

    // Check the on-disk cache async so we don't block the main thread
    NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:delegate, @"delegate", url, @"url", nil];
    [[PhotoCache sharedImageCache] queryDiskCacheForKey:[url absoluteString] delegate:self userInfo:info];
}

- (void)cancelForDelegate:(id<PhotoManagerDelegate>)delegate
{
    NSUInteger idx = [delegates indexOfObjectIdenticalTo:delegate];
    
    if (idx == NSNotFound)
    {
        return;
    }
    
    PhotoDownloader *downloader = [[downloaders objectAtIndex:idx] retain];
    
    [delegates removeObjectAtIndex:idx];
    [downloaders removeObjectAtIndex:idx];
    
    if (![downloaders containsObject:downloader])
    {
        // No more delegate are waiting for this download, cancel it
        [downloader cancel];
    }
    
    [downloader release];
}

#pragma mark PhotoDownloaderDelegate

- (void)imageDownloader:(PhotoDownloader *)downloader didFinishWithImage:(UIImage *)image
{
    [downloader retain];
    
    // Notify all the delegates with this downloader
    for (NSInteger idx = [downloaders count] - 1; idx >= 0; idx--)
    {
        PhotoDownloader *aDownloader = [downloaders objectAtIndex:idx];
        if (aDownloader == downloader)
        {
            id<PhotoManagerDelegate> delegate = [delegates objectAtIndex:idx];
            
            if (image && [delegate respondsToSelector:@selector(photoManager:didFinishWithImage:)])
            {
                [delegate performSelector:@selector(photoManager:didFinishWithImage:) withObject:self withObject:image];
            }
            
            [downloaders removeObjectAtIndex:idx];
            [delegates removeObjectAtIndex:idx];
        }
    }
        
    
    // Release the downloader
    [downloaderForURL removeObjectForKey:downloader.url];
    [downloader release];
}


@end

