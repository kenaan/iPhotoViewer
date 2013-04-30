//
//  ContentCode.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/15/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import "ContentCode.h"


@implementation ContentCode
@synthesize number, name, type;

- (id)initWithName:(NSString *)n type:(ContentType)t number:(uint32_t)num {
    if ((self = [super init])) {
        self.name = n;
        self.type = t;
        self.number = num;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"ContentCode name: %@ type: %d number: %d", self.name, self.type, self.number]; 
}

- (void)dealloc {
    [name release];
    [super dealloc];
}
@end


