//
//  Client.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/12/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import "Client.h"
#import "Utils.h"
#import "ContentParser.h"
#import "Database.h"
#import "ErrorSupport.h"
#import "Photo.h"
#import "Globals.h"

#define ASSERT_NODE(node, problem) if (node == nil) {\
    error = [ErrorSupport createError:kErrorConnectNoData]; \
    break; \
}
 
@interface Client ()

- (NSError*)loadDatabase;

@end

static Client* clientInstance;

@implementation Client

@synthesize address, port, sessionId, bag = _bag, database = _database, delegate, isConnected;

+ (Client*)instance {
    return clientInstance;
}

- (void)setBag:(ContentCodeBag *)b {
    [_bag release];
    _bag = [b retain];
}

- (void)dealloc {
    [address release];
    [_bag release];

    clientInstance = nil;
    [super dealloc];
}

- (id)initWithHost:(NSString*)host port:(NSInteger)portNumber
{
    if ((self = [super init])) {
        self.address = [Utils hostToIP:host];
        self.port = portNumber;
        self.sessionId = 0;
        self.isConnected = NO;
        clientInstance = self;
    }
    return self;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@:%d", self.address, self.port];
}

- (ASIHTTPRequest*)prepareRequest:(NSString*)path query:(NSString*)query 
{
    
    NSString* urlStr = [NSString stringWithFormat:@"http://%@:%d%@", self.address, self.port, path];
    
    if (sessionId != 0) {
        NSString* sessionSuffix = [NSString stringWithFormat:@"session-id=%li", sessionId];
        if (query == nil)
            query = sessionSuffix;
        else
            query = [query stringByAppendingFormat:@"&%@", sessionSuffix];
    }
    
    if (query != nil) {
        urlStr = [urlStr stringByAppendingFormat:@"?%@", query];
    }
    
    //NSLog(@"%@", urlStr);          
    NSURL *url = [NSURL URLWithString:urlStr];
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    
    request.shouldAttemptPersistentConnection = NO;
    [request addRequestHeader:@"Accept" value:@"*/*"];

    request.userAgent = @"iPhoto/9.2.1 (Macintosh; N; PPC)";
    [request addRequestHeader:@"Client-DPAP-Version" value:@"1.1"];
    
    [request setUsername:@"none"];
    [request setPassword:nil];

    return request;
}

- (NSError*)fetch:(NSString*)path query:(NSString*)query responseData:(NSData**)pData {
    ASIHTTPRequest* request = [self prepareRequest:path query:query];
    [request startSynchronous];
    NSError *error = nil;
    do {
        error = [request error];
        if (error) {        
            NSLog(@"Error: %@", error.localizedDescription);
            break;
        }
        
        if ([request responseStatusCode] != 200) {
            error = [ErrorSupport createError:kErrorErrorHttpRequest parameter:[NSString stringWithFormat:@"code: %d - %@", [request responseStatusCode], [request responseStatusMessage]]];
            break;
        }
        *pData = [request responseData];
    } while (false);
        
    return error;
}

- (NSError*)doConnect {    
    
    if ([self.delegate respondsToSelector:@selector(clientDidStartConnect:)])
        [self.delegate clientDidStartConnect:self];
    
    NSError* error = nil;
    do {
        NSData* contentCodes;
        error = [self fetch:@"/content-codes" query:nil responseData:&contentCodes];
        if (error)
            break;
        
        ASSERT_NODE(contentCodes, @"content-codes");
        
        self.bag = [ContentCodeBag parseCodes:contentCodes error:&error];
        
        if (error)
            break;
        
        if (self.bag == nil)
            break;
        
        
        NSData* login;
        error = [self fetch:@"/login" query:nil responseData:&login];
        if (error)
            break;
        
        ASSERT_NODE(login, @"login");
        
        ContentNode* loginNode = [ContentParser parse:self.bag buffer:(void*)[login bytes] error:&error];
        
        if (error)
            break;
        
        ASSERT_NODE(loginNode, @"loginNode");

        ContentNode* sessionIdNode = [loginNode getChild:@"dmap.sessionid"];
        
        ASSERT_NODE(sessionIdNode, @"sessionId");
        
        self.sessionId = [(NSNumber*)sessionIdNode.value longValue];
        
    } while (false);

    return error;
}

- (void)connect
{

    NSError* error = nil;
    
    do {
        error = [self doConnect];
        
        if (error)
            break;
        //NSLog(@"sessionId: %li", sessionId);       
        
                     
        NSData* dbs;
        error = [self fetch:@"/databases" query:nil responseData:&dbs];
        if (error)
            break;
            
        ASSERT_NODE(dbs, @"databases");
        
        ContentNode* dbnode = [ContentParser parse:self.bag buffer:(void*)[dbs bytes] error:&error];
        
        if (error)
            break;
        
        ASSERT_NODE(dbnode, @"dbnode");
        
        ContentNode* dbListNode = [dbnode getChild:@"dmap.listing"];
            
        self.database = [[Database alloc] init];
        
        ContentNode* itemId = [dbListNode getChild:@"dmap.itemid"];
        self.database.dbId = [(NSNumber*)itemId.value intValue];

        if ([self.delegate respondsToSelector:@selector(client:databaseAdded:)])
            [self.delegate client:self databaseAdded:self.database];
        
        [self loadDatabase];

        if ([self.delegate respondsToSelector:@selector(client:databaseLoaded:)])
            [self.delegate client:self databaseLoaded:self.database];
            
        
        self.isConnected = YES;
        
        if ([self.delegate respondsToSelector:@selector(clientConnected:)])
            [self.delegate clientConnected:self];

    } while (false);
    
    if ([self.delegate respondsToSelector:@selector(clientDidFinishConnect:)])
        [self.delegate clientDidFinishConnect:self];
    
    if (error)
        [[NSNotificationCenter defaultCenter] postNotificationName:kConnectErrorNotification object:error];
    

}

- (void)disconnect
{
    NSData* logout;
    [self fetch:@"/logout" query:nil responseData:&logout];
    self.isConnected = NO;

    [_database release];
    _database = nil;
    
    if ([self.delegate respondsToSelector:@selector(clientDisconnected:)])
        [self.delegate clientDisconnected:self];
}

- (NSError*)loadAlbums {
    NSLog(@"======== Loading albums =============");
    NSError* error = nil;
    do {
        NSData* albumsData;
        error = [self fetch:[NSString stringWithFormat:@"/databases/%d/containers", self.database.dbId]
                                     query: @"meta=dpap.aspectratio,dmap.itemid,dmap.itemname,dpap.imagefilename,dpap.imagefilesize,dpap.creationdate,dpap.imagepixelwidth,dpap.imagepixelheight,dpap.imageformat,dpap.imagerating,dpap.imagecomments,dpap.imagelargefilesize&type=photo" responseData:&albumsData];
        
        if (error)
            break;
        
        ASSERT_NODE(albumsData, @"albumsData empty");
        
        ContentNode* albumsNode = [ContentParser parse:self.bag buffer:(void*)[albumsData bytes] error:&error];
        
        if (error)
            break;
        
        if (albumsNode == nil) {
            NSLog(@"albumsNode nil");
            break;
        }
        
        //[albumsNode dump];
        
        if ([albumsNode.name isEqual:@"dmap.updateresponse"])
            break;
        
        // handle album additions/changes
        ContentNode* dmapListing = [albumsNode getChild:@"dmap.listing"];
        if (dmapListing == nil)
            break;
        
        for (ContentNode* albumNode in dmapListing.value) {
            int albumId = 0;
            NSString* albumName = nil;
            ContentNode* countNode = [albumNode getChild:@"dmap.itemcount"];
            int itemsCount = [countNode.value intValue];
            if (itemsCount == 0)
                continue;
                
            albumId = [(NSNumber*)[albumNode getChild:@"dmap.itemid"].value intValue];
            albumName = [albumNode getChild:@"dmap.itemname"].value;
            [self.database addAlbum:albumId name:albumName];
        }
    } while (false);
    return error;
}

- (NSError*)loadPhotos {
    NSLog(@"======== Loading photos =============");
    NSError* error = nil;
    do {
        NSMutableSet* photoIds = [NSMutableSet set];
        for (id album in self.database.albums){
            NSMutableArray* albumPhotoIds = [NSMutableArray array];
            int albumId = [album intValue];
            NSData* photosData;
            error = [self fetch:[NSString stringWithFormat:@"/databases/%d/containers/%d/items", self.database.dbId, albumId] 
                                       query:@"meta=dpap.aspectratio,dmap.itemid,dmap.itemname,dpap.imagefilename,dpap.imagefilesize,dpap.creationdate,dpap.imagepixelwidth,dpap.imagepixelheight,dpap.imageformat&type=photo" responseData:&photosData];
            
            if (error)
                break;
            
            ASSERT_NODE(photosData, @"photosData")
            
            ContentNode* photosNode = [ContentParser parse:self.bag buffer:(void *)[photosData bytes] error:&error];
            
            if (error)
                break;
            
            if (!photosNode) {
                NSLog(@"photosNode is nil");
                continue;
            }
            

            for (ContentNode* photoNode in [photosNode getChild:@"dmap.listing"].value) {
                Photo* photo = [[Photo alloc] initFromNode:photoNode];
                NSNumber* photoId = [NSNumber numberWithInt:photo.photoId];
                [albumPhotoIds addObject:photoId];
                [self.database.photos setObject:photo forKey:photoId];
                [photo release];
            }
            
            [self.database addPhotoIds:albumPhotoIds forAlbum:album];
            [photoIds addObjectsFromArray:albumPhotoIds];        
        }
        
        [self.database.photoIds addObjectsFromArray:[photoIds allObjects]];
        [self.database.photoIds sortUsingSelector:@selector(compare:)];
    } while (false);
    
    return error;
}

- (NSError*)loadDatabase {
    NSError* error = nil;
    do {
        error = [self loadAlbums];
        if (error)
            break;
        error = [self loadPhotos];
    } while (false);
    return error;
}

@end
