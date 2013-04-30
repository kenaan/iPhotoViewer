//
//  ErrorSupport.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 2/3/12.
//  Copyright 2012 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>

// error codes
enum {
	kErrorNotConnected = 1,
	kErrorConnection,
    kErrorConnectTimeout,
    kErrorConnectNoData,
    kErrorParsingContentCodeNotFound,
    kErrorParsingUnknownContentType,
    kErrorParsingRootNodeNotFound,
    kErrorErrorHttpRequest
};


@interface ErrorSupport : NSObject {

}

+ (NSError*)createError:(NSInteger)errorCode;
+ (NSError*)createError:(NSInteger)errorCode parameter:(id)param;

@end
