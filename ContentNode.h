//
//  ContentNode.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/15/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ContentNode : NSObject

- (id)initWithName:(NSString*)n values:(NSArray*)values;
- (ContentNode *)getChild:(NSString*)n;
- (void)dump;

@property (retain) NSString* name;
@property (assign) id value;

@end
