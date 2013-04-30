//
//  CollectionViewController.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 12/16/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//
#import "KTThumbsViewController.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "TwitterAgent.h"
#import "FacebookAgent.h"
#import "PhotoDataSource.h"

@interface CollectionViewController : KTThumbsViewController<PhotoDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate, TwitterAgentDelegate, FacebookAgentDelegate, UIDocumentInteractionControllerDelegate> {
@protected
    UIActivityIndicatorView *activityIndicatorView;
    PhotoDataSource* _images;
    UIDocumentInteractionController* _docController;
    NSURL* _fileUrl;
}

- (void)showActivityIndicator;
- (void)hideActivityIndicator;


@property NSUInteger selectedPhotoIndex;
@property (assign) PhotoDataSource* images;
@end
