//
//  ContentCode.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/15/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    kContentTypeChar = 1,
    kContentTypeSignedLong = 2,
    kContentTypeShort = 3,
    kContentTypeLong = 5,
    kContentTypeLongLong = 7,
    kContentTypeString = 9,
    kContentTypeDate = 10,
    kContentTypeVersion = 11,
    kContentTypeContainer = 12,
    kContentTypeFileData = 13
} ContentType;


@interface ContentCode : NSObject 

- (id) initWithName:(NSString*)n type:(ContentType)t number:(uint32_t)num;

@property uint32_t number;
@property (retain) NSString* name;
@property ContentType type;
@end;

