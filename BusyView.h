//
//  BusyView.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 12/24/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BusyView : UIAlertView {
    UIActivityIndicatorView *activityView;
}

@property (nonatomic, retain) UIActivityIndicatorView *activityView;

- (void) close;

@end
