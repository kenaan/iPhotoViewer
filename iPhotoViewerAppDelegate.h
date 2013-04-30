//
//  iPhotoViewerAppDelegate.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 11/8/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface iPhotoViewerAppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *_window;
    UINavigationController *_navigationController;
    UISplitViewController *_splitViewController;
}

@property (retain, nonatomic) UIWindow *window;
@property (retain, nonatomic) UINavigationController *navigationController;
@property (retain, nonatomic) UISplitViewController *splitViewController;

@end
