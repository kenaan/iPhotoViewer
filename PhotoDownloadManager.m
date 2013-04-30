//
//  PhotoDownloadManager.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/28/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "PhotoDownloadManager.h"
#import "Database.h"
#import "Client.h"
#import "SDImageCache.h"
#import "UIImage+Resizing.h"
#import "Globals.h"

@interface PhotoDownloadManager()
- (void)setup;

@property BOOL isAlbumDownloader;

@end

@implementation PhotoDownloadManager

@synthesize albumId, count, isAlbumDownloader;

- (id)init
{
    if ((self = [super init]))
    {
        self.isAlbumDownloader = NO;
        [self setup];
    }
    return self;
}

- (id)initWithAlbum:(int)alId
{
    if ((self = [super init]))
    {
        self.isAlbumDownloader = YES;
        self.albumId = alId;
        Client* client = [Client instance];
        self.count = [[client.database.albumPhotoIds objectForKey:[NSNumber numberWithInt:alId]] count];
        [self setup];
    }
    return self;
}

- (void)setup {
    downloaders = [[NSMutableArray alloc] init];
    delegates = [[NSMutableArray alloc] init];
    downloaderForIndex = [[NSMutableDictionary alloc] init];
    thumbDownloadDelegates = [[NSMutableDictionary alloc] init];
    thumbsDownloader = [[ThumbsDownloader alloc] init];
    thumbsDownloader.delegate = self;
    thumbsDownloader.isAlbumDownloader = self.isAlbumDownloader;
    thumbsDownloader.albumId = self.albumId;
}

- (void)dealloc
{
    [delegates release];
    delegates = nil;
    [downloaders release];
    downloaders = nil;
    [downloaderForIndex release];
    downloaderForIndex = nil;
    [thumbDownloadDelegates release];
    thumbDownloadDelegates = nil;
    [super dealloc];
}

- (void)downloadPhotoAtIndex:(NSUInteger)idx delegate:(id<PhotoDownloadManagerDelegate>)delegate
{
    NSNumber* index = [NSNumber numberWithUnsignedInteger:idx];
    if (idx > self.count)
        return;
    
    PhotoDownloader* downloader = [downloaderForIndex objectForKey:index];
    if (!downloader) {
        if (self.isAlbumDownloader)
            downloader = [[[PhotoDownloader alloc] initWithAlbum:self.albumId index:idx] autorelease];
        else
            downloader = [[[PhotoDownloader alloc] initWithIndex:idx] autorelease];
        downloader.delegate = self;
        
        [downloader startDownload];

    } else {
        NSLog(@"Downloader found for index %d! IT'S WRONG!", idx);
    }
    
    [delegates addObject:delegate];
    [downloaders addObject:downloader];
}


- (void)cancelForDelegate:(id<PhotoDownloadManagerDelegate>)delegate
{
    NSUInteger idx = [delegates indexOfObjectIdenticalTo:delegate];
    
    if (idx != NSNotFound)
    {
        PhotoDownloader *downloader = [[downloaders objectAtIndex:idx] retain];
        
        [delegates removeObjectAtIndex:idx];
        [downloaders removeObjectAtIndex:idx];
        
        if (![downloaders containsObject:downloader])
        {
            // No more delegate are waiting for this download, cancel it
            [downloader cancelDownload];
            [downloaderForIndex removeObjectForKey:[NSNumber numberWithUnsignedInteger:idx]];
        }
        
        [downloader release];
    }
    
    NSNumber* thumbIndex = [[thumbDownloadDelegates allKeysForObject:delegate] lastObject];
    if (thumbIndex) {
        [thumbDownloadDelegates removeObjectForKey:thumbIndex];
    }
}

- (NSString*)getKeyForIndex:(NSUInteger)index isHiRes:(BOOL)isHiRes {
    Client* client = [Client instance];
    NSString* key = [NSString stringWithFormat:@"%@/%d/%d/%d-%d", [client description], 
                     client.database.dbId, self.albumId, index, isHiRes];
    return key;
}

- (UIImage*)imageAtIndex:(NSUInteger)index isHiRes:(BOOL)isHiRes {
    return [[SDImageCache sharedImageCache] imageFromKey:[self getKeyForIndex:index isHiRes:isHiRes]];
}

- (void)setDelegate:(id<PhotoDownloadManagerDelegate>)delegate forThumbnailWithIndex:(NSUInteger)index {
    [thumbDownloadDelegates setObject:delegate forKey:[NSNumber numberWithInt:index]];
}

- (void)downloadThumbsFromIndex:(NSInteger)startIndex until:(NSInteger)stopIndex {
    thumbsDownloader.startIndex = startIndex;
    thumbsDownloader.stopIndex = stopIndex;
}

- (void)startThumbsDownload {
    [thumbsDownloader startDownload];
}

#pragma mark -
#pragma mark PhotoDownloaderDelegate 

- (void)photoDownloader:(PhotoDownloader *)downloader didFinishWithImage:(UIImage *)image
{
    NSNumber* index = [NSNumber numberWithUnsignedInteger:downloader.index];
    NSUInteger dIndex = downloader.index;
    NSString* key = [self getKeyForIndex:dIndex isHiRes:YES];
    
    UIImage* fitToScreenImage = [image scaleToFitScreenSize];
    // Notify all the delegates with this downloader
    for (NSInteger idx = [downloaders count] - 1; idx >= 0; idx--)
    {
        PhotoDownloader *aDownloader = [downloaders objectAtIndex:idx];
        if (aDownloader == downloader)
        {
            if (image) {
                id<PhotoDownloadManagerDelegate> delegate = [delegates objectAtIndex:idx];
                [delegate downloadManager:self didFinishWithImage:fitToScreenImage key:key];
            }
            [downloaders removeObjectAtIndex:idx];
            [delegates removeObjectAtIndex:idx];
        }
    }
    
    if (image)
    {
        [[SDImageCache sharedImageCache] storeImage:fitToScreenImage forKey:key];
        [[SDImageCache sharedImageCache] storeImageToDisk:image forKey:key];
    }     
    
    // Release the downloader
    [downloaderForIndex removeObjectForKey:index];
    //[downloader release];
}

- (void)photoDownloader:(PhotoDownloader *)downloader didFailWithError:(NSError *)error
{
    NSNumber* index = [NSNumber numberWithUnsignedInteger:downloader.index];
    // Notify all the delegates with this downloader
    for (NSInteger idx = [downloaders count] - 1; idx >= 0; idx--)
    {
        PhotoDownloader *aDownloader = [downloaders objectAtIndex:idx];
        if (aDownloader == downloader)
        {
            id<PhotoDownloadManagerDelegate> delegate = [delegates objectAtIndex:idx];
            [delegate downloadManager:self didFailWithError:error];
                                         
            [downloaders removeObjectAtIndex:idx];
            [delegates removeObjectAtIndex:idx];
        }
    }
    
    // Release the downloader
    [downloaderForIndex removeObjectForKey:index];
    //[downloader release];
 
}

#pragma mark -
#pragma mark ThumbsDownloaderDelegate

- (void)thumbsDownloader:(ThumbsDownloader *)dldr didFailWithError:(NSError *)error {
    for (NSNumber* idx in thumbDownloadDelegates) {
        id<PhotoDownloadManagerDelegate> delegate = [thumbDownloadDelegates objectForKey:idx];
        [delegate downloadManager:self didFailWithError:error];
    }
    [thumbDownloadDelegates removeAllObjects];
}

- (void)thumbsDownloader:(ThumbsDownloader *)dldr didFinishWithImage:(UIImage *)image atIndex:(NSInteger)index {
    NSNumber* idx = [NSNumber numberWithInt:index];
    id<PhotoDownloadManagerDelegate> delegate = [thumbDownloadDelegates objectForKey:idx];
    [delegate downloadManager:self didFinishWithImage:image];
    [thumbDownloadDelegates removeObjectForKey:idx];
    
    if (image)
    {
        [[SDImageCache sharedImageCache] storeImage:image forKey:[self getKeyForIndex:index isHiRes:NO]];
    }     
    
}

@end
