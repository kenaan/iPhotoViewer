//
//  main.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/8/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iPhotoViewerAppDelegate.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];

    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([iPhotoViewerAppDelegate class]));
    [pool release];
    return retVal;
}
