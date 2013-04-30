//
//  Utils.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/15/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Utils : NSObject {
    
}
+ (uint16_t) bitConverterToInt16:(const unsigned char*)buf offset:(int)offset;
+ (uint32_t) bitConverterToInt32:(const unsigned char*)buf offset:(int)offset;
+ (uint64_t) bitConverterToInt64:(const unsigned char*)buf offset:(int)offset;
+ (const char*) bitConverterGetBytes:(int)num;
+ (NSString*) hostToIP:(NSString*)host;

@end
