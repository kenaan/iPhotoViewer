//
//  CollectionViewController.m
//  iPhotoViewer
//
//  Created by Leon Meerson on 12/16/11.
//  Copyright (c) 2011 Total Liberation Front. All rights reserved.
//

#import "CollectionViewController.h"

@interface CollectionViewController()
- (void)cleanupDocController; 
@end


@implementation CollectionViewController

@synthesize selectedPhotoIndex, images = _images;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [self cleanupDocController];
    [activityIndicatorView release];
    [super dealloc];
}

- (void)emailPhoto
{
    UIImage *image = [self.images imageAtIndex:self.selectedPhotoIndex];
    if (!image)
        return;
    
    MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
    mail.mailComposeDelegate = self;
    if ([MFMailComposeViewController canSendMail]) {
        //Setting up the Subject, recipients, and message body.
        //[mail setToRecipients:[NSArray arrayWithObjects:@"address@example.com",nil]];
        
        [mail setSubject:@"Sent from iPhotoViewer"];
        
        NSData *exportData = UIImageJPEGRepresentation(image, 1.0);
        [mail addAttachmentData:exportData mimeType:@"image/jpeg" fileName:@"photo.jpeg"];
        //Present the mail view controller
        [self presentModalViewController:mail animated:YES];
    }
    //release the mail
    [mail release];
}

- (void)savePhoto
{
    UIImage *image = [self.images imageAtIndex:self.selectedPhotoIndex];
    if (!image)
        return;
    
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, 0);
}

- (void)postOnTwitter {
    UIImage *image = [self.images imageAtIndex:self.selectedPhotoIndex];
    if (!image)
        return;
    
    [TwitterAgent uploadImage:image delegate:self];
}

- (void)postOnFacebook {
    UIImage *image = [self.images imageAtIndex:self.selectedPhotoIndex];
    if (!image)
        return;
    
    [FacebookAgent uploadImage:image delegate:self];
}
/*
- (void)openInInstagram
{
    UIImage *image = [images imageAtIndex:self.selectedPhotoIndex];
    if (!image)
        return;
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSError* error;
    int attempts = 0;
    NSString* path;
    do {
        path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"photo%d.ig", attempts]];
        if ([fileMgr fileExistsAtPath:path])
            [fileMgr removeItemAtPath:path error:&error];
    } while (error != 0 && ++attempts < 3);
    
    if (error) {
        NSLog(@"error creating file");
        return;
    }
    
    NSURL* url = [NSURL fileURLWithPath:path];
    UIDocumentInteractionController *interactionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    //interactionController.delegate = self;
    interactionController.UTI = @"com.instagram.photo";
    
    [interactionController presentOpenInMenuFromRect:CGRectMake(50.0f, 50.0f, 20.0f, 20.0f) inView:[self view] animated:YES];
}
*/

#pragma mark -
#pragma mark Instagram


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)openInInstagram  {
    [self cleanupDocController];
    UIImage *image = [self.images imageAtIndex:self.selectedPhotoIndex];
    if (!image)
        return;
    
    // Instagram requires that images are at least 612x612 and preferably square.
    if (image.size.width < 612 || image.size.height < 612) {
        NSLog(@"Image size is under 612");
        return;
    }
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsPath = [paths objectAtIndex:0];
    NSString* destinationPath = [documentsPath stringByAppendingPathComponent:
                                 [NSString stringWithFormat:@"instagram-image-%.0f.ig",
                                  [NSDate timeIntervalSinceReferenceDate]]];
    
    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
    [imageData writeToFile:destinationPath atomically:YES];
    
    _fileUrl = [NSURL URLWithString:[@"file:" stringByAppendingString:destinationPath]];
    _docController = [[UIDocumentInteractionController interactionControllerWithURL:_fileUrl]
                          retain];
    _docController.delegate = self;
    [_docController presentOpenInMenuFromRect: CGRectZero
                                       inView: self.view
                                     animated: YES];
}
/*
- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
    //[self cleanupDocController];
}
*/
- (void)cleanupDocController {
    if (_docController) {
        [_docController release];
        _docController = nil;
    }
    if (_fileUrl)
        [[NSFileManager defaultManager] removeItemAtURL:_fileUrl error:nil];
}


#pragma mark -
#pragma mark PhotoDataDelegate

#define kButtonSave 0
#define kButtonEmail 1
#define kButtonTwitter 2
#define kButtonFacebook 3
#define kButtonInstagram 4

- (void)exportImageAtIndex:(NSUInteger)index photoView:(UIView *)photoView
{
    UIImage *image = [self.images imageAtIndex:index];
    if (!image)
        return;
    
    self.selectedPhotoIndex = index;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    [actionSheet addButtonWithTitle:@"Save photo"];
    [actionSheet addButtonWithTitle:@"Email photo"];
    [actionSheet addButtonWithTitle:@"Post on Twitter"];
    [actionSheet addButtonWithTitle:@"Post on Facebook"];
    BOOL haveInstagram = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram:"]];
    if (haveInstagram)
        [actionSheet addButtonWithTitle:@"Send to Instagram..."];
    [actionSheet addButtonWithTitle:@"Cancel"];
    actionSheet.cancelButtonIndex = actionSheet.numberOfButtons - 1;
    
    [actionSheet showInView:photoView];
    [actionSheet release];
}

#pragma mark -
#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
        case kButtonEmail:
            [self emailPhoto];
            break;
        case kButtonSave:
            [self savePhoto];
            break;
        case kButtonTwitter:
            [self postOnTwitter];
            break;
        case kButtonFacebook:
            [self postOnFacebook];
            break;
        case kButtonInstagram:
            [self openInInstagram];
            break;
        defaul:
            break;
    }
    
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self.navigationController dismissModalViewControllerAnimated:YES];
    
}

#pragma mark -
#pragma mark Social networks

- (void)twitterAgentFinished:(TwitterAgent *)agent {
    // [agent release];
}

- (void)facebookAgentFinished:(FacebookAgent *)agent {
    
}

#pragma mark -
#pragma mark Activity


- (void)willLoadThumbs 
{
    [self showActivityIndicator];
    [super willLoadThumbs];
}

- (void)didLoadThumbs 
{
    [self hideActivityIndicator];
}


#pragma mark -
#pragma mark Activity Indicator

- (UIActivityIndicatorView *)activityIndicator 
{
    if (activityIndicatorView) {
        return activityIndicatorView;
    }
    
    activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    CGPoint center = [[self view] center];
    [activityIndicatorView setCenter:center];
    [activityIndicatorView setHidesWhenStopped:YES];
    [activityIndicatorView startAnimating];
    [[self view] addSubview:activityIndicatorView];
    
    return activityIndicatorView;
}

- (void)showActivityIndicator 
{
    [[self activityIndicator] startAnimating];
}

- (void)hideActivityIndicator 
{
    [[self activityIndicator] stopAnimating];
}

@end
