#pragma once
//
//  Photo.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/18/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ContentNode;

@interface Photo : NSObject {
    int photoId;
    NSString* title;
    NSString* format;
    NSString* filename;
    int size;
    NSDate* dateCreated;
    int height;
    int width;
}

@property int photoId;
@property (retain) NSString* title;
@property (retain) NSString* format;
@property (retain) NSString* filename;
@property (retain) NSDate* dateCreated;
@property int size;
@property int height;
@property int width;


- (id)initFromNode:(ContentNode*)node;

@end
