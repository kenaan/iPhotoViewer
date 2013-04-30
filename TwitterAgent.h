//
//  TwitterAgent.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 12/4/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIFormDataRequest.h"
#import "PostPhotoView.h"

@class GTMOAuthAuthentication;
@class TwitterAgent;

@protocol TwitterAgentDelegate <NSObject>

- (void)twitterAgentFinished:(TwitterAgent*)agent;

@end


@interface TwitterAgent : NSObject<ASIHTTPRequestDelegate, UIAlertViewDelegate, PostPhotoViewDelegate>

//- (id)initWithDelegate:(UIViewController<TwitterAgentDelegate>*)dlg;
+ (void)uploadImage:(UIImage*)image delegate:(UIViewController<TwitterAgentDelegate>*)dlg;

@end
