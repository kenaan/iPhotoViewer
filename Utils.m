//
//  Utils.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/15/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import "Utils.h"
#include <stdio.h>
#include <stdlib.h>
#include <netdb.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <arpa/inet.h>


@implementation Utils


+ (uint16_t) bitConverterToInt16:(const unsigned char*)buf offset:(int)offset
{
    return (buf[0 + offset] << 0) | (buf[1 + offset] << 8);    
}

+ (uint32_t) bitConverterToInt32:(const unsigned char*)buf offset:(int)offset
{
    return (buf[0 + offset] << 0) | (buf[1 + offset] << 8) | (buf[2 + offset] << 16) | (buf[3 + offset] << 24);    
}

+ (uint64_t) bitConverterToInt64:(const unsigned char*)buf offset:(int)offset
{
    return (buf[0 + offset] << 0) | (buf[1 + offset] << 8) | (buf[2 + offset] << 16) | (buf[3 + offset] << 24) | ((uint64_t)buf[4 + offset] << 32) | ((uint64_t)buf[1 + offset] << 40) | ((uint64_t)buf[2 + offset] << 48) | ((uint64_t)buf[3 + offset] << 56);    
}

+ (const char*) bitConverterGetBytes:(int)num
{
    static char buf[5];
    buf[4] = 0;
    memcpy(buf, &num, 4);
    return buf;
}

+ (NSString*) hostToIP:(NSString *)host 
{    
    struct hostent *he;
    struct in_addr **addr_list;
    
    if ((he = gethostbyname([host cStringUsingEncoding:[NSString defaultCStringEncoding]])) != NULL) {  // get the host info
        addr_list = (struct in_addr **)he->h_addr_list;
        char* addr = inet_ntoa(*addr_list[0]);
        return [NSString stringWithCString:addr encoding:[NSString defaultCStringEncoding]];            
    }
    return nil;
}
    


@end
