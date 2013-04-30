//
//  Photo.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/18/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "Photo.h"
#import "ContentNode.h"
#import "Database.h"

@implementation Photo

@synthesize photoId, title, format, filename, size, dateCreated, height, width;


- (id)initFromNode:(ContentNode *)node
{
    if ((self = [super init])) {
        for (ContentNode* field in node.value) {
            if ([field.name isEqual:@"dmap.itemid"])
                self.photoId = [field.value intValue];
            else if ([field.name isEqual:@"dmap.itemname"])
                self.title = field.value;
            else if ([field.name isEqual:@"dpap.imageformat"])
                self.format = field.value;
            else if ([field.name isEqual:@"dpap.imagefilename"])
                self.filename = field.value;
            else if ([field.name isEqual:@"dpap.imagefilesize"])
                self.size = [field.value intValue];
            else if ([field.name isEqual:@"dpap.imagepixelwidth"])
                self.width = [field.value intValue];
            else if ([field.name isEqual:@"dpap.imagepixelheight"])
                self.height = [field.value intValue];
            else if ([field.name isEqual:@"dpap.creationdate"])
                self.dateCreated = field.value;
        }
    }
    return self;
}

- (void)dealloc {
    [self.title release];
    [self.format release];
    [self.filename release];
    [self.dateCreated release];
    [super dealloc];
}

@end
