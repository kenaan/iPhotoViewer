//
//  PostPhotoView.h
//  iPhotoViewer
//
//  Created by Leon Meerson on 12/6/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PostPhotoView;

@protocol PostPhotoViewDelegate <NSObject>

- (void)postPhotoViewCancel:(PostPhotoView*)postView;
- (void)postPhotoViewSend:(PostPhotoView*)postView message:(NSString*)message;

@end

@interface PostPhotoView : NSObject<UIAlertViewDelegate, UITextViewDelegate> 

- (id)initWithTitle:(NSString *)title image:(UIImage*)image;
- (id)initWithTitle:(NSString *)title image:(UIImage*)image maxMessageLength:(int)maxLength;
- (void)show;

@property (assign) id<PostPhotoViewDelegate> delegate;

@end
