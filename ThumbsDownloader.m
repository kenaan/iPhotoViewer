///
//  ThumbsDownloader.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 1/20/12.
//  Copyright 2012 Total Liberation Front. All rights reserved.
//

#import "ThumbsDownloader.h"
#import "Client.h"
#import "Database.h"
#import "ContentParser.h"
#import "ErrorSupport.h"

#define kMaxBatchSize 10

@implementation ThumbsDownloader

@synthesize delegate, startIndex, stopIndex, isAlbumDownloader, albumId;
/*
- (id)init {
    self = [super init];
    if (self) {
        _photoIds = [[NSMutableDictionary alloc] init];
    }
    return self;
}
*/

- (void)cleanup {    
    if (_photoIds)
        [_photoIds release];
    _photoIds = nil;
}

- (void)dealloc {
    [self cleanup];
    [super dealloc];
}

- (void)startDownload {
    //NSLog(@"Start download from index %d to %d", startIndex, stopIndex);
    Client* client = [Client instance];
    Database* db = client.database;
    [self cleanup];    
    _photoIds = [[NSMutableDictionary alloc] initWithCapacity:stopIndex - startIndex];
    NSMutableArray* albumPhotoIds = self.isAlbumDownloader ? [db.albumPhotoIds objectForKey:[NSNumber numberWithInt:albumId]] : nil;

    for (int index = startIndex; index < stopIndex; index++) {
        NSNumber* key = nil;
        if (isAlbumDownloader) {
            key = [albumPhotoIds objectAtIndex:index];
        } else {
            key = [db.photoIds objectAtIndex:index];
        }
            
        [_photoIds setObject:[NSNumber numberWithInt:index] forKey:key];
            
    }

    NSString* allItems = nil;
     
    int nCount = 0;
    
    int nItems = [_photoIds count];
    
    for (NSNumber* photoId in _photoIds) {
        
        NSString* item = [NSString stringWithFormat:@"'dmap.itemid:%d'", [photoId intValue]];

        if (allItems == nil)
            allItems = item;
        else
            allItems = [allItems stringByAppendingFormat:@",%@", item];
        
        ++nCount;
        
        if (nCount >= nItems || (nCount % kMaxBatchSize) == 0) {
            NSString* query = [NSString stringWithFormat:@"meta=dpap.thumb,dpap.filedata&query=(%@)", allItems];
            ASIHTTPRequest* request = [client prepareRequest:[NSString stringWithFormat:@"/databases/%d/items", client.database.dbId] 
                                                       query:query];
            [request setDelegate:self];
            [request startAsynchronous];
            allItems = nil;
        }
    }
}



- (void)requestFailed:(ASIHTTPRequest *)request {
    [self.delegate thumbsDownloader:self didFailWithError:[request error]];
    [self cleanup];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    Client* client = [Client instance];
    if ([request responseStatusCode] != 200) {
        NSError* error = [ErrorSupport createError:kErrorErrorHttpRequest parameter:[NSString stringWithFormat:@"code: %d - %@", [request responseStatusCode], [request responseStatusMessage]]];
        [self.delegate thumbsDownloader:self didFailWithError:error];
    } else {
        NSData* imageData = [request responseData];
        NSError* error = nil;
        ContentNode* node = [ContentParser parse:client.bag buffer:(void *)[imageData bytes] error:&error];
        if (error) 
            [self.delegate thumbsDownloader:self didFailWithError:error];
        else {
            for (ContentNode* imageNode in [node getChild:@"dmap.listing"].value) {
                ContentNode* idNode = [imageNode getChild:@"dmap.itemid"];
                NSNumber* photoId = idNode.value;
                NSNumber* index = [_photoIds objectForKey:photoId];
                ContentNode* fileDataNode = [imageNode getChild:@"dpap.filedata"];
                int offset = [fileDataNode.value intValue];
                //NSLog(@"Photo starts at index %d",  offset);
                UIImage* image = [UIImage imageWithData:[NSData dataWithBytes:(const void *)([imageData bytes] + offset) length:(imageData.length - offset)]];
                [self.delegate thumbsDownloader:self didFinishWithImage:image atIndex:[index intValue]];
            }
        }
    }
}
        


@end
