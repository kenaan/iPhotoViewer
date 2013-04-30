//
//  FacebookAgent.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 12/5/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostPhotoView.h"
#import "FBConnect.h"

@class FacebookAgent;

@protocol FacebookAgentDelegate <NSObject>

- (void)facebookAgentFinished:(FacebookAgent*)agent;

@end


@interface FacebookAgent : NSObject<FBSessionDelegate, FBRequestDelegate, PostPhotoViewDelegate> {
    Facebook* facebook;
}

@property (nonatomic, retain) Facebook *facebook;
@property (assign) id<FacebookAgentDelegate> delegate;

+ (void)uploadImage:(UIImage*)image delegate:(id<FacebookAgentDelegate>)dlg;

@end
