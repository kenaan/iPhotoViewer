//
//  PostPhotoView.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 12/6/11.
//  Copyright 2011 Total Liberation Front. All rights reserved.
//

#import "PostPhotoView.h"

@interface PostPhotoView()

@property (retain) UIAlertView* messageDialog;
@property (retain) UITextView* txtMessage;
@property int maxMessageLength;
@end

@implementation PostPhotoView

@synthesize delegate;
@synthesize messageDialog, txtMessage, maxMessageLength;

- (id)initWithTitle:(NSString *)title image:(UIImage*)image {
    return [self initWithTitle:title image:image maxMessageLength:1024];
}

- (id)initWithTitle:(NSString *)title image:(UIImage*)image maxMessageLength:(int)maxLength {
    if ((self = [super init])) {
        self.maxMessageLength = maxLength;
        txtMessage = [[UITextView alloc] initWithFrame:CGRectMake(80, 50, 175, 60)];
        UIImageView* preview = [[[UIImageView alloc] initWithFrame:CGRectMake(25, 55, 50, 50)] autorelease];
        [preview setContentMode:UIViewContentModeScaleAspectFit];
        preview.image = image;
        
        txtMessage.backgroundColor = [UIColor whiteColor];
        txtMessage.delegate = self;
        
        messageDialog = [[UIAlertView alloc] initWithTitle:title message:@"\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send",nil];
            
        [messageDialog addSubview:preview];
        [messageDialog addSubview:txtMessage];
        [messageDialog bringSubviewToFront:txtMessage];
        [txtMessage becomeFirstResponder];
    }
    return self;
}

- (void)dealloc {
    [txtMessage release];
    [messageDialog release];
    [super dealloc];
}
- (void)show {
    [messageDialog show];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
	const char* str = [text UTF8String];
	
	int s = str[0];
	if(s != 0 && (range.location + range.length) > self.maxMessageLength)
        return NO;
    
    return YES;
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self.delegate postPhotoViewSend:self message:self.txtMessage.text];
    } else {
        [self.delegate postPhotoViewCancel:self];
    }
}


@end
