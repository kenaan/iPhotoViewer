//
//  Client.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/12/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentCodeBag.h"
#import "ASIHTTPRequest.h"

@class Database;
@class Client;

@protocol ClientDelegate <NSObject>
@optional
- (void)clientDidStartConnect:(Client*)client;
- (void)clientDidFinishConnect:(Client*)client;
- (void)clientConnected:(Client*)client;
- (void)clientDisconnected:(Client*)client;
- (void)client:(Client*)client databaseAdded:(Database*)database;
- (void)client:(Client*)client databaseLoaded:(Database*)database;
- (void)client:(Client*)client connectDidFailWithError:(NSError*)error;

@end

@interface Client : NSObject<ASIHTTPRequestDelegate> {    
@private
    ContentCodeBag* _bag;
    Database* _database;
}

@property (retain) NSString* address;
@property long sessionId;
@property NSInteger port;
@property (nonatomic, assign) ContentCodeBag* bag;
@property (nonatomic, assign) Database* database;
@property (nonatomic, assign) id<ClientDelegate> delegate;
@property BOOL isConnected;

- (id)initWithHost:(NSString*)host port:(NSInteger)port;
- (void)connect;
- (void)disconnect;
- (ASIHTTPRequest*)prepareRequest:(NSString*)path query:(NSString*)query;

+ (Client*)instance;

@end
