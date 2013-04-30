//
//  ContentCodeBag.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/13/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//
#import "ContentCodeBag.h"
#import "Utils.h"
#import "ContentCode.h"
#import "ContentParser.h"
#include <Foundation/NSByteOrder.h>


@implementation ContentCodeBag

@synthesize codes;

- (NSMutableDictionary*)codes
{
    if (codes == nil) {
        codes = [[NSMutableDictionary alloc] init];
    }
    return codes;
}

- (void)dealloc {
    [codes release];
    [super dealloc];
}

+ (uint32_t)getIntFormat:(NSString*)code
{
    const char* buf = [code cStringUsingEncoding:NSASCIIStringEncoding];
    uint32_t codeHost = [Utils bitConverterToInt32:(const unsigned char*)buf offset:0];
    uint32_t ret = NSSwapBigIntToHost(codeHost);
    return ret;
    //return IPAddress.NetworkToHostOrder (BitConverter.ToInt32 (Encoding.ASCII.GetBytes (code), 0));
}

+ (NSString*)getStringFormat:(int)code 
{
    int codeNetwork = NSSwapHostIntToBig(code);
    const char* buf = [Utils bitConverterGetBytes:codeNetwork];
    return [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
    //return Encoding.ASCII.GetString (BitConverter.GetBytes (IPAddress.HostToNetworkOrder (code)));
}

- (void)addCode:(NSString*)num name:(NSString*)name type:(ContentType)type
{
    ContentCode* code = [[[ContentCode alloc] initWithName:name type:type number:[ContentCodeBag getIntFormat:num]] autorelease];
    [self.codes setObject:code forKey:[NSNumber numberWithUnsignedInt:code.number]];
    //NSLog(@"addCode: %@", code);
}

+ (ContentCodeBag*)parseCodes:(NSData*)contentCodes error:(NSError**)pError
{
    ContentCodeBag* bag = [[[ContentCodeBag alloc] init] autorelease];
    
    // add some codes to bootstrap us
    [bag addCode:@"mccr" name:@"dmap.contentcodesresponse" type:kContentTypeContainer];
    [bag addCode:@"mdcl" name:@"dmap.dictionary" type:kContentTypeContainer];
    [bag addCode:@"mcnm" name:@"dmap.contentcodesnumber" type:kContentTypeLong];
    [bag addCode:@"mcna" name:@"dmap.contentcodesname" type:kContentTypeString];
    [bag addCode:@"mcty" name:@"dmap.contentcodestype" type:kContentTypeShort];
    [bag addCode:@"mstt" name:@"dmap.status" type:kContentTypeLong];
    // added
    [bag addCode:@"mlog" name:@"dmap.loginresponse" type:kContentTypeContainer];
    [bag addCode:@"mlid" name:@"dmap.sessionid" type:kContentTypeLong];

    // some photo-specific codes
    // shouldn't be needed now
    [bag addCode:@"ppro" name:@"dpap.protocolversion" type:kContentTypeLong];
    [bag addCode:@"pret" name:@"dpap.blah" type:kContentTypeContainer];
    [bag addCode:@"avdb" name:@"dpap.serverdatabases" type:kContentTypeContainer];
    [bag addCode:@"aply" name:@"dpap.databasecontainers" type:kContentTypeContainer];
    [bag addCode:@"abpl" name:@"dpap.baseplaylist" type:kContentTypeChar];
    [bag addCode:@"apso" name:@"dpap.playlistsongs" type:kContentTypeContainer];
    [bag addCode:@"pasp" name:@"dpap.aspectratio" type:kContentTypeString];
    [bag addCode:@"adbs" name:@"dpap.databasesongs" type:kContentTypeContainer];
    [bag addCode:@"picd" name:@"dpap.creationdate" type:kContentTypeLong];
    [bag addCode:@"pifs" name:@"dpap.imagefilesize" type:kContentTypeLong];
    [bag addCode:@"pwth" name:@"dpap.imagepixelwidth" type:kContentTypeLong];
    [bag addCode:@"phgt" name:@"dpap.imagepixelheight" type:kContentTypeLong];
    [bag addCode:@"pcmt" name:@"dpap.imagecomments" type:kContentTypeString];
    [bag addCode:@"prat" name:@"dpap.imagerating" type:kContentTypeLong];
    [bag addCode:@"pimf" name:@"dpap.imagefilename" type:kContentTypeString];
    [bag addCode:@"pfmt" name:@"dpap.imageformat" type:kContentTypeString];
    [bag addCode:@"plsz" name:@"dpap.imagelargefilesize" type:kContentTypeLong];
    [bag addCode:@"pfdt" name:@"dpap.filedata" type:kContentTypeFileData];
    
    ContentNode* node = [ContentParser parse:bag buffer:(void*)[contentCodes bytes] error:pError];
    
    for (ContentNode* dictNode in node.value) {
        if ([dictNode.name isEqualToString:@"dmap.dictionary"] == NO)
            continue;
        
        ContentCode* code = [[[ContentCode alloc] init] autorelease];
        
        for (ContentNode* item in dictNode.value) {
            if ([item.name isEqual:@"dmap.contentcodesnumber"])
                code.number = [(NSNumber*)item.value intValue];
            else if ([item.name isEqual:@"dmap.contentcodesname"])
                code.name = item.value;
            else if ([item.name isEqual:@"dmap.contentcodestype"])
                code.type = [(NSNumber*)item.value shortValue];
        }
        
        //NSLog(@"%@", code);
        [bag.codes setObject:code forKey:[NSNumber numberWithInt:code.number]];
    }

    return bag;
}

- (ContentCode*)lookup:(int)number {
    id ret = [self.codes objectForKey:[NSNumber numberWithInt:number]];
    if (ret)
        return ret;
    else
        return nil;
}
/*
- (ContentCode*)lookup:(NSString*)name {
    for (id key in codes) {
        id ret = [codes objectForKey:key];
        if ([ret isEqual:name])
            return ret;
    }
    
    return nil;
}
*/
@end
