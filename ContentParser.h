//
//  ContentParser.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/13/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentCodeBag.h"
#import "ContentNode.h"

@interface ContentParser : NSObject 

+ (NSArray*)parseChildren:(ContentCodeBag*)bag buffer:(void*)buffer offset:(int)offset length:(int)length error:(NSError**)pError;
+ (ContentNode*)parse:(ContentCodeBag*)bag buffer:(void*)buffer root:(NSString*)root offset:(int*)offset error:(NSError**)pError; 
+ (ContentNode*)parse:(ContentCodeBag*)bag buffer:(void*)buffer root:(NSString*)root error:(NSError**)pError; 
+ (ContentNode*)parse:(ContentCodeBag*)bag buffer:(void*)buffer error:(NSError**)pError; 

@end
