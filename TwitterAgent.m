//
//  TwitterAgent.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 12/4/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "TwitterAgent.h"
#import "GTMOAuthViewControllerTouch.h"

static NSString *const kTwitterKeychainItemName = @"iPhotoViewer: Twitter";
static NSString *const kTwitterServiceName = @"Twitter";

#define TWITPIC_API_KEY @"304c3f7223554ca60fdd15dad912d78b"
#define TWITTER_OAUTH_CONSUMER_KEY @"Fc4BXO6RNvTXGjlxnujuKg"
#define TWITTER_OAUTH_CONSUMER_SECRET @"t2n6479RQ1OWhAI6wAFNnanUwWMJsRwmSUTL90v0ds"

#define kAuthenticationDialog 1

TwitterAgent* twitterAgent = nil;

@interface TwitterAgent()
- (void)viewController:(GTMOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuthAuthentication *)auth
                 error:(NSError *)error;
- (void)incrementNetworkActivity:(NSNotification *)notify;
- (void)decrementNetworkActivity:(NSNotification *)notify;
- (void)signInNetworkLostOrFound:(NSNotification *)notify;
- (GTMOAuthAuthentication *)authForTwitter;
- (void)setAuthentication:(GTMOAuthAuthentication *)auth;
- (BOOL)isSignedIn;
- (void)signInToTwitter;
- (BOOL)setup;
- (void)uploadImageWithMessage:(NSString*)message;
- (void)showPostDialog;

@property (assign) UIViewController<TwitterAgentDelegate>* delegate;
@property (retain) GTMOAuthAuthentication *mAuth;
@property int mNetworkActivityCounter;
@property (assign) UIImage* image;
@end

@implementation TwitterAgent

@synthesize delegate, mAuth, mNetworkActivityCounter, image;

- (BOOL)setup {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(incrementNetworkActivity:) name:kGTMOAuthFetchStarted object:nil];
    [nc addObserver:self selector:@selector(decrementNetworkActivity:) name:kGTMOAuthFetchStopped object:nil];
    [nc addObserver:self selector:@selector(signInNetworkLostOrFound:) name:kGTMOAuthNetworkLost  object:nil];
    [nc addObserver:self selector:@selector(signInNetworkLostOrFound:) name:kGTMOAuthNetworkFound object:nil];
    
    // Get the saved authentication, if any, from the keychain.
    //
    // The view controller supports methods for saving and restoring
    // authentication under arbitrary keychain item names; see the
    // "keychainForName" methods in the interface.  The keychain item
    // names are up to the application, and may reflect multiple accounts for
    // one or more services.
    //
    // This sample app may have saved one Google authentication and one Twitter
    // auth.  First, we'll try to get the saved Google authentication, if any.
    GTMOAuthAuthentication *auth;

    auth = [self authForTwitter];
    BOOL didAuth = NO;
    if (auth) {
        didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:kTwitterKeychainItemName
                                                                  authentication:auth];
    }
    
    
    // save the authentication object, which holds the auth tokens
    [self setAuthentication:auth];

    return didAuth;
}

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [mAuth release];
    [super dealloc];
}

- (BOOL)isSignedIn {
    BOOL isSignedIn = [mAuth canAuthorize];
    return isSignedIn;
}


- (GTMOAuthAuthentication *)authForTwitter {
    // Note: to use this sample, you need to fill in a valid consumer key and
    // consumer secret provided by Twitter for their API
    //
    // http://twitter.com/apps/
    //
    // The controller requires a URL redirect from the server upon completion,
    // so your application should be registered with Twitter as a "web" app,
    // not a "client" app
    NSString *myConsumerKey = TWITTER_OAUTH_CONSUMER_KEY;
    NSString *myConsumerSecret = TWITTER_OAUTH_CONSUMER_SECRET;
    
    if ([myConsumerKey length] == 0 || [myConsumerSecret length] == 0) {
        return nil;
    }
    
    GTMOAuthAuthentication *auth;
    auth = [[[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                        consumerKey:myConsumerKey
                                                         privateKey:myConsumerSecret] autorelease];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    [auth setServiceProvider:kTwitterServiceName];
    
    return auth;
}


- (void)signOut {
    // remove the stored Twitter authentication from the keychain, if any
    [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:kTwitterKeychainItemName];
    
    // Discard our retained authentication object.
    [self setAuthentication:nil];
}


- (void)signInToTwitter {
    
    [self signOut];
    
    NSURL *requestURL = [NSURL URLWithString:@"http://twitter.com/oauth/request_token"];
    NSURL *accessURL = [NSURL URLWithString:@"http://twitter.com/oauth/access_token"];
    NSURL *authorizeURL = [NSURL URLWithString:@"http://twitter.com/oauth/authorize"];
    NSString *scope = @"http://api.twitter.com/";
    
    GTMOAuthAuthentication *auth = [self authForTwitter];

    // set the callback URL to which the site should redirect, and for which
    // the OAuth controller should look to determine when sign-in has
    // finished or been canceled
    //
    // This URL does not need to be for an actual web page; it will not be
    // loaded
    [auth setCallback:@"http://www.example.com/OAuthCallback"];
    
    NSString *keychainItemName = kTwitterKeychainItemName;
    
    // Display the autentication view.
    GTMOAuthViewControllerTouch *viewController;
    viewController = [[[GTMOAuthViewControllerTouch alloc] initWithScope:scope
                                                                language:nil
                                                         requestTokenURL:requestURL
                                                       authorizeTokenURL:authorizeURL
                                                          accessTokenURL:accessURL
                                                          authentication:auth
                                                          appServiceName:keychainItemName
                                                                delegate:self
                                                        finishedSelector:@selector(viewController:finishedWithAuth:error:)] autorelease];
    
    // We can set a URL for deleting the cookies after sign-in so the next time
    // the user signs in, the browser does not assume the user is already signed
    // in
    [viewController setBrowserCookiesURL:[NSURL URLWithString:@"http://api.twitter.com/"]];
    
    // You can set the title of the navigationItem of the controller here, if you want.
    
    [[self.delegate navigationController] pushViewController:viewController animated:YES];
}

- (void)viewController:(GTMOAuthViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuthAuthentication *)auth
                 error:(NSError *)error {
    if (error != nil) {
        // Authentication failed (perhaps the user denied access, or closed the
        // window before granting access)
        NSLog(@"Authentication error: %@", error);
        NSData *responseData = [[error userInfo] objectForKey:@"data"]; // kGTMHTTPFetcherStatusDataKey
        if ([responseData length] > 0) {
            // show the body of the server's authentication failure response
            NSString* str = [[[NSString alloc] initWithData:responseData
                                                   encoding:NSUTF8StringEncoding] autorelease];
            NSLog(@"%@", str);
        }
        
        [self setAuthentication:nil];
        UIAlertView* authenticationErrorDlg = [[[UIAlertView alloc] initWithTitle:@"Authentication error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        authenticationErrorDlg.tag = kAuthenticationDialog;
        [authenticationErrorDlg show];
    } else {
        // Authentication succeeded
        //
        // At this point, we either use the authentication object to explicitly
        // authorize requests, like
        //
        //   [auth authorizeRequest:myNSURLMutableRequest]
        //
        // or store the authentication object into a GTM service object like
        //
        //   [[self contactService] setAuthorizer:auth];
        
        // save the authentication object
        [self setAuthentication:auth];
        [self showPostDialog];
    }    
}

#pragma mark -

- (void)incrementNetworkActivity:(NSNotification *)notify {
    ++mNetworkActivityCounter;
    if (1 == mNetworkActivityCounter) {
        UIApplication *app = [UIApplication sharedApplication];
        [app setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)decrementNetworkActivity:(NSNotification *)notify {
    --mNetworkActivityCounter;
    if (0 == mNetworkActivityCounter) {
        UIApplication *app = [UIApplication sharedApplication];
        [app setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)signInNetworkLostOrFound:(NSNotification *)notify {
    if ([[notify name] isEqual:kGTMOAuthNetworkLost]) {
        // network connection was lost; alert the user, or dismiss
        // the sign-in view with
        //   [[[notify object] delegate] cancelSigningIn];
    } else {
        // network connection was found again
    }
}

#pragma mark -

- (void)setAuthentication:(GTMOAuthAuthentication *)auth {
    [mAuth autorelease];
    mAuth = [auth retain];
}

#pragma mark -

- (void)uploadImageWithMessage:(NSString*)message {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.twitpic.com/1/uploadAndPost.json"]];
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    
    [request addPostValue:TWITPIC_API_KEY forKey:@"key"];
    [request addPostValue:TWITTER_OAUTH_CONSUMER_KEY forKey:@"consumer_token"];
    [request addPostValue:TWITTER_OAUTH_CONSUMER_SECRET forKey:@"consumer_secret"];
    [request addPostValue:mAuth.token forKey:@"oauth_token"];
    [request addPostValue:mAuth.tokenSecret forKey:@"oauth_secret"];
    [request addPostValue:message forKey:@"message"];
    [request addData:UIImageJPEGRepresentation(self.image, 0.8) forKey:@"media"];
    
    request.requestMethod = @"POST";
    request.delegate = self;
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"Request finished!");
    NSLog(@"Response status code: %d", [request responseStatusCode]);
    NSLog(@"Response message: %@", [request responseStatusMessage]);
    NSLog(@"Response string: %@", [request responseString]);
    if (([request responseStatusCode] != 200)) {
        UIAlertView* failureDialog = [[[UIAlertView alloc] initWithTitle:@"Post failed" message:[request responseStatusMessage] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [failureDialog show];         
    } else {
        UIAlertView* successDialog = [[[UIAlertView alloc] initWithTitle:@"Post successful!" message:nil delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
        [successDialog show];          
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"Request failed: %@", [request error]);
    UIAlertView* failureDialog = [[[UIAlertView alloc] initWithTitle:@"Post failed" message:[[request error] localizedDescription] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
    [failureDialog show];    
    [self.delegate twitterAgentFinished:self];    
}

+ (void)uploadImage:(UIImage *)image delegate:(UIViewController<TwitterAgentDelegate> *)dlg {
    if (twitterAgent == nil) {
        twitterAgent = [[TwitterAgent alloc] init];
    }
    twitterAgent.delegate = dlg;
    twitterAgent.image = image;
    if ([twitterAgent setup]) {
        [twitterAgent showPostDialog];
    } else
        [twitterAgent signInToTwitter];
}

- (void)showPostDialog {
    PostPhotoView* postDialog = [[PostPhotoView alloc] initWithTitle:@"Post to Twitter" image:self.image maxMessageLength:120];
    postDialog.delegate = self;
    [postDialog show];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAuthenticationDialog)
        [[self.delegate navigationController] popViewControllerAnimated:YES];
    [self.delegate twitterAgentFinished:self];
}

- (void)postPhotoViewSend:(PostPhotoView *)postView message:(NSString*)message {
    [self uploadImageWithMessage:message];
    [postView release];
}

- (void)postPhotoViewCancel:(PostPhotoView *)postView {
    [postView release];
}
@end
