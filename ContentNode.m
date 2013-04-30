//
//  ContentNode.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/15/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import "ContentNode.h"


@implementation ContentNode

@synthesize name, value;

- (id)initWithName:(NSString*)n values:(NSArray*)values {
    if ((self = [super init])) {
        self.name = n;
        NSMutableArray* vals = [NSMutableArray arrayWithCapacity:[values count]];
        for (id v in values) {
            if ([v isKindOfClass:[NSArray class]]) {
                [vals addObjectsFromArray:v];
            } else {
                [vals addObject:v];            
            }            
        }
        if (([vals count] == 1) && (NO == [[vals objectAtIndex:0] isKindOfClass:[ContentNode class]])) {
            self.value = [vals objectAtIndex:0];        
        }
        else
            self.value = vals;
    }
    return self;
}

- (ContentNode *)getChild:(NSString*)n {
    //NSLog(@"getChild: %@", n);
    if ([self.name isEqual:n])
        return self;
    
    if ([self.value isKindOfClass:[NSArray class]] == NO)
        return nil;
    
    for (id child in self.value) {
        ContentNode* needle = [child getChild:n];
        if (needle != nil)
            return needle;
    }
    return nil;
        
}

- (void)dump:(int)level {
    char buf[64];
    for (int i = 0; i < level*4; i++)
        buf[i] = ' ';
    buf[level*4] = 0;
    NSString* empty = [NSString stringWithCString:buf encoding:NSASCIIStringEncoding];
    
    NSLog(@"%@Name: %@", empty, self.name);
    if ([self.value isKindOfClass:[NSArray class]]) {
        for (ContentNode* child in self.value)
            [child dump:level+1];
    } else {
        NSLog(@"%@Value (%@): %@", empty, [[self.value class] description], self.value);
    }
}

- (void)dump {
    [self dump:0];
}

- (void)dealloc {
    [name release];
    [super dealloc];
}
@end
