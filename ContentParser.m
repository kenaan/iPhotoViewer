//
//  ContentParser.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/13/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import "ContentParser.h"
#import "Utils.h"
#import "ContentCode.h"
#import "ErrorSupport.h"
#include <Foundation/NSByteOrder.h>

@implementation ContentParser

   
+ (NSArray*)parseChildren:(ContentCodeBag*)bag buffer:(void*)buffer offset:(int)offset length:(int)length error:(NSError**)pError
{
    //NSLog(@"parseChildren: offset: %d length: %d", offset, length);
    NSMutableArray* children = [NSMutableArray array];
    int position = offset;

    while (position < offset + length) {
        //NSLog(@"position: %d out of %d", position, offset+length);
        ContentNode* node = [ContentParser parse:bag buffer:buffer root:nil offset:&position error:pError];
        if (*pError)
            break;
        
        [children addObject:node];
        //NSLog(@"Parsed on position: %d:", position);
        //[node dump];
    }
        
    return children;
}
    
+ (ContentNode*)parse:(ContentCodeBag*)bag buffer:(void*)buffer root:(NSString*)root offset:(int*)offset error:(NSError**)pError{
    char codeStr[5]; codeStr[4]=0;
    memcpy(codeStr, buffer, 4);
    //NSLog(@"parsing %s", codeStr);

    ContentNode* node = [[[ContentNode alloc] init] autorelease];
    uint32_t n = [Utils bitConverterToInt32:(const unsigned char*)buffer offset:*offset];
    uint32_t num = NSSwapBigIntToHost(n);
    ContentCode* code = nil;
    
    // This is a fix for iPhoto '08 which gives wrong content-type for dpap.databasecontainers (aply)
    if (num == 1634757753) {
        code = [[[ContentCode alloc] initWithName:@"dpap.databasecontainers" type:kContentTypeContainer number:num] autorelease];
    }
    else
        code = [bag lookup:num];
    
    if ([code.name isEqual:@"dpap.filedata"])
        code.type = kContentTypeFileData;
    
    if (code == nil) {
        *pError = [ErrorSupport createError:kErrorParsingContentCodeNotFound parameter:[NSNumber numberWithInteger:num]];
        return nil;
    }
        
    int length = NSSwapBigIntToHost([Utils bitConverterToInt32:(const unsigned char *)buffer offset:*offset + 4]);
/*
        
        if (code.Equals (ContentCode.Zero)) {
            throw new ContentException (String.Format ("Failed to find content code for '{0}'.  Data length is {1}",
                                                       ContentCodeBag.GetStringFormat (num), length));
        }*/
        
    node.name = code.name;
        
    int vMajor, vMinor, vMicro;
    unsigned char *ptr = (unsigned char *)(buffer + *offset  + 8);
    char* tmpBuf; 
    
    switch (code.type) {
        case kContentTypeChar:
            node.value = [NSNumber numberWithUnsignedChar:ptr[0]];
            break;
        case kContentTypeShort:
            node.value = [NSNumber numberWithUnsignedShort:NSSwapBigShortToHost([Utils bitConverterToInt16:ptr offset:0])];
            break;
        case kContentTypeSignedLong:
        case kContentTypeLong:
            node.value = [NSNumber numberWithUnsignedInt:NSSwapBigIntToHost([Utils bitConverterToInt32:ptr offset:0])];
            break;
        case kContentTypeLongLong:
            node.value = [NSNumber numberWithUnsignedLong:NSSwapBigLongToHost([Utils bitConverterToInt64:ptr offset:0])];
            break;
        case kContentTypeString:
            tmpBuf = (char*)malloc(length+1);
            tmpBuf[length]=0;
            memcpy(tmpBuf, ptr, length);
            node.value = [NSString stringWithCString:tmpBuf encoding:NSASCIIStringEncoding];
            free(tmpBuf);
            break;
        case kContentTypeDate:
            node.value = [NSDate dateWithTimeIntervalSince1970:NSSwapBigIntToHost([Utils bitConverterToInt32:ptr offset:0])];
            break;
        case kContentTypeVersion:
            vMajor = NSSwapBigIntToHost([Utils bitConverterToInt16:ptr offset:0]);
            vMinor = (int) *(ptr + 2);
            vMicro = (int) *(ptr + 3);                
            node.value = [NSString stringWithFormat:@"%d.%d.%d", vMajor, vMinor, vMicro];
            break;
        case kContentTypeContainer:
            node.value = [ContentParser parseChildren:bag buffer:buffer offset:(*offset+8) length:length error:pError];
            break;
        case kContentTypeFileData:
            node.value = [NSNumber numberWithInt:(*offset+8)];
            break;
        default:
            *pError = [ErrorSupport createError:kErrorParsingUnknownContentType parameter:[NSString stringWithFormat:@"%d for %@", code.type, code.name]];
            return nil;
    }
    //NSLog(@"name = %@ Code=%d num=%d value: %@", node.name, code.type, num, node.value);
        
    *offset += length + 8;
    
    if (root != nil) {
        ContentNode* rootNode = [node getChild:root];
        
        if (rootNode == nil) {
            *pError = [ErrorSupport createError:kErrorParsingRootNodeNotFound parameter:root];
            return nil;

        }
        
        return rootNode;
    } 
    //[node dump:0];
    return node;
}
    
+ (ContentNode*)parse:(ContentCodeBag*)bag buffer:(void*)buffer root:(NSString*)root error:(NSError**)pError {
    int offset = 0;
    return [ContentParser parse:bag buffer:buffer root:root offset:&offset error:pError];
}
    
+ (ContentNode*)parse:(ContentCodeBag*)bag buffer:(void*)buffer error:(NSError**)pError {
    //NSLog(@"======= Start parsing ===========");
    return [ContentParser parse:bag buffer:buffer root:nil error:pError];
}
    
@end
