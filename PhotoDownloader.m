//
//  PhotoDownloader.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/28/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "PhotoDownloader.h"
#import "Client.h"
#import "Database.h"
#import "Client.h"
#import "ContentParser.h"
#import "ErrorSupport.h"

@interface PhotoDownloader()

@property BOOL isAlbumDownloader;

@end

@implementation PhotoDownloader

@synthesize delegate, index, image = _image, isAlbumDownloader;

#pragma mark

- (id)initWithIndex:(NSUInteger)idx 
{
    if ((self = [super init])) {
        self.index = idx;
    }
    return self;
}
   
- (id)initWithAlbum:(int)alId index:(NSUInteger)idx
{
    if ((self = [self initWithIndex:idx])) {
        albumId = alId;
        isAlbumDownloader = YES;
    }
    return self;
}

- (void)startDownload
{
    Client* client = [Client instance];
    Database* db = client.database;

    if (isAlbumDownloader) {
        NSMutableArray* albumPhotoIds = [db.albumPhotoIds objectForKey:[NSNumber numberWithInt:albumId]];
        photoId = [[albumPhotoIds objectAtIndex:self.index] intValue];
    } else {
        photoId = [[db.photoIds objectAtIndex:self.index] intValue];
    }

    NSString* queryFormat = @"meta=dpap.hires,dpap.filedata&query=('dmap.itemid:%d')";
    request = [client prepareRequest:[NSString stringWithFormat:@"/databases/%d/items", client.database.dbId] 
                                                         query:[NSString stringWithFormat:queryFormat, photoId]];
    [request setDelegate:self];
    [request startAsynchronous];
}
    
- (void)cancelDownload
{
    NSLog(@"Cancel download at index %d", self.index);
    [request clearDelegatesAndCancel];
}

- (void)didFinishWithImage:(UIImage*)image
{
    self.image = image;
    [self.delegate photoDownloader:self didFinishWithImage:self.image];
}

- (void)didFailWithError:(NSError*)error
{
    [self.delegate photoDownloader:self didFailWithError:error];
}

- (void)dealloc {
    [_image release];
    [super dealloc];
}

- (void)requestFailed:(ASIHTTPRequest *)_request {
    [self didFailWithError:[_request error]];
}

- (void)requestFinished:(ASIHTTPRequest *)_request {
    Client* client = [Client instance];
    if ([request responseStatusCode] != 200) {
        NSError* error = [ErrorSupport createError:kErrorErrorHttpRequest parameter:[NSString stringWithFormat:@"code: %d - %@", [request responseStatusCode], [request responseStatusMessage]]];
        [self didFailWithError:error];
    } else {
        NSData* imageData = [_request responseData];
        NSError* error = nil;
        ContentNode* node = [ContentParser parse:client.bag buffer:(void *)[imageData bytes] error:&error];
        if (error)
            [self didFailWithError:error];
        else {
            ContentNode* fileDataNode = [node getChild:@"dpap.filedata"];
            int offset = [fileDataNode.value intValue];
            //NSLog(@"Photo starts at index %d",  offset);
            UIImage* image = [UIImage imageWithData:[NSData dataWithBytes:(const void *)([imageData bytes] + offset) length:(imageData.length - offset)]];
            [self didFinishWithImage:image];
        }
    }   
}

@end
