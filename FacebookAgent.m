//
//  FacebookAgent.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 12/5/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "FacebookAgent.h"

static NSString* kAppId = @"329620333731857";

FacebookAgent* facebookAgent = nil;

@interface FacebookAgent()

- (void)showPostDialog;
- (void)uploadImageWithMessage:(NSString*)message;

@property (assign) UIImage* image;

@end

@implementation FacebookAgent

@synthesize facebook, image, delegate;

- (id)init {
    if ((self = [super init])) {
        // Initialize Facebook
        facebook = [[Facebook alloc] initWithAppId:kAppId andDelegate:self];
    }
    return self;
}

- (void)dealloc {
    [facebook release];
    [super dealloc];
}

- (BOOL)setup {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    return ([facebook isSessionValid]);
}

- (void)clearAuth {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
        
        // Nil out the session variables to prevent
        // the app from thinking there is a valid session
        if (nil != [facebook accessToken]) {
            facebook.accessToken = nil;
        }
        if (nil != [facebook expirationDate]) {
            facebook.expirationDate = nil;
        }
    }
}

/**
 * Show the authorization dialog.
 */
- (void)login {
    facebook.sessionDelegate = self;
    //[facebook authorize:[NSArray arrayWithObjects:@"offline_access", nil]];
    NSArray * neededPermissions = [[[NSArray alloc] initWithObjects:@"user_about_me", @"publish_stream", @"user_photos", nil] autorelease];
    [facebook authorize:neededPermissions];

}

/**
 * Invalidate the access token and clear the cookie.
 */
- (void)logout {
    [facebook logout:self];
}

#pragma mark - FBSessionDelegate Methods
/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
    NSLog(@"fbDidLogin");
    // Save authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"did not login");
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
    [self clearAuth];
}
#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    //NSLog(@"received response");
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Err message: %@", [[error userInfo] objectForKey:@"error_msg"]);
    NSLog(@"Err code: %d", [error code]);
    
    // Show logged out state if:
    // 1. the app is no longer authorized
    // 2. the user logged out of Facebook from m.facebook.com or the Facebook app
    // 3. the user has changed their password
    if ([error code] == 190) {
        [self clearAuth];
    }
}


#pragma mark -

+ (void)uploadImage:(UIImage*)image delegate:(id<FacebookAgentDelegate>)dlg {
    if (facebookAgent == nil) {
        facebookAgent = [[FacebookAgent alloc] init];
    }
    facebookAgent.delegate = dlg;
    facebookAgent.image = image;
    if ([facebookAgent setup]) {
        [facebookAgent showPostDialog];
    } else
        [facebookAgent login];
}

- (void)showPostDialog {
    PostPhotoView* postDialog = [[PostPhotoView alloc] initWithTitle:@"Post on Facebook" image:self.image];
    postDialog.delegate = self;
    [postDialog show];
}

- (void)uploadImageWithMessage:(NSString*)message {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys: image, @"source", 
                                   message, @"message",             
                                       nil];
    [facebook requestWithGraphPath:[NSString stringWithFormat:@"/me/photos?access_token=%@", self.facebook.accessToken]
                             andParams:params andHttpMethod:@"POST" andDelegate:self];
}

- (void)postPhotoViewCancel:(PostPhotoView *)postView {
    [postView release];
}

- (void)postPhotoViewSend:(PostPhotoView *)postView message:(NSString *)message {
    [self uploadImageWithMessage:message];
    [postView release];
}
@end
