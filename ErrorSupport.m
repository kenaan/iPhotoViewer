//
//  ErrorSupport.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 2/3/12.
//  Copyright 2012 Total Liberation Front. All rights reserved.
//

#import "ErrorSupport.h"
@interface ErrorSupport()

+  (NSArray*) errorsList;

@end


@implementation ErrorSupport

static NSArray* _errorsList = nil;
static NSString* const kErrorDomain = @"com.GTC.iPhotoViewer";

+  (NSArray*) errorsList {
    if (_errorsList == nil)
        _errorsList = [NSArray arrayWithObjects:
                       @"Not connected",
                       @"Connection error occurred",
                       @"Connect timed out",
                       @"Invalid data received during connect",
                       @"Error parsing response: content code %d not found",
                       @"Error parsing response: unknown content type %@",
                       @"Error parsing response: could not find root node '%@'",
                       @"HTTP response error: %@", nil];
    return _errorsList;
}

+ (NSError*) createError:(NSInteger)code
{
	NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:[[ErrorSupport errorsList] objectAtIndex:code], NSLocalizedDescriptionKey, nil];
	NSError* error = [[[NSError alloc] initWithDomain:kErrorDomain code:code userInfo:usrInfo] autorelease];
	return error;
}

+ (NSError*)createError:(NSInteger)code parameter:(id)param {
	NSDictionary *usrInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:[[ErrorSupport errorsList] objectAtIndex:code-1], param], NSLocalizedDescriptionKey, nil];
	NSError* error = [[[NSError alloc] initWithDomain:kErrorDomain code:code userInfo:usrInfo] autorelease];
	return error;
    
}

@end
