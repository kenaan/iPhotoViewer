//
//  ContentCodeBag.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/13/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContentCode.h"

@interface ContentCodeBag : NSObject

@property (nonatomic, retain) NSMutableDictionary* codes;

+ (ContentCodeBag*) parseCodes:(NSData*)contentCodes error:(NSError**)pError;
- (ContentCode*) lookup:(int)code;
//- (ContentCode*) lookup:(NSString*)name;

@end
