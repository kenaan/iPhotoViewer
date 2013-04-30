#pragma once
//
//  Database.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/17/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Photo;
@class ContentNode;
@class Database;

@protocol DatabaseDelegate <NSObject>

@optional
- (void)database:(Database*)database albumAddedAtIndex:(NSInteger)index;
- (void)database:(Database*)database albumRemovedAtIndex:(NSInteger)index;
- (void)database:(Database*)database photosAddedForAlbum:(NSNumber*)album;
@end

@interface Database : NSObject {
    NSMutableDictionary* _photos;
    NSMutableArray* _photoIds;
    NSMutableArray* _albums;
    NSMutableDictionary* _albumNames;
    NSMutableDictionary* _albumPhotoIds;
}

- (void)addAlbum:(int)albumId name:(NSString*)albumName;
- (void)addPhotoIds:(NSMutableArray*)photoIds forAlbum:(NSNumber*)album;

@property int dbId;
@property (retain) NSMutableDictionary* photos;
@property (retain) NSMutableDictionary* albumNames;
@property (retain) NSMutableDictionary* albumPhotoIds;
@property (retain) NSMutableArray* albums;
@property (retain) NSMutableArray* photoIds;
@property (assign) id<DatabaseDelegate> delegate;


@end
