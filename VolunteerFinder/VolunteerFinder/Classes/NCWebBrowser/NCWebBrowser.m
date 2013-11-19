//
//  NCWebBrowser.m
//
//  Created by Brandon Jones.
//  Copyright 2013 nclud, LLC. All rights reserved.
//

#import "NCWebBrowser.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import "TUSafariActivity.h"

@interface NCWebBrowser (private)
- (UIImage *)imageNamed:(NSString *)name;
- (void)showLoading:(BOOL)loading;
- (void)highlightLoadingImage;
- (void)unhighlightLoadingImage;
- (void)setupWebView;
- (void)setupToolbar;
@end

static inline double degreesToRadians(double degrees) {return degrees * M_PI / 180;};
static inline double radiansToDegrees(double radians) {return radians * 180 / M_PI;};

@implementation NCWebBrowser
@synthesize webView, toolbar, backButton, forwardButton, reloadButton, stopButton, loadingImage, request;

- (id)init
{
    self = [super init];
    if (self) {

        //setup the view
        [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self setHidesBottomBarWhenPushed:YES];
        [self setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self setModalPresentationStyle:UIModalPresentationFormSheet];
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    //activity sheet button
    if (self.navigationItem) {
        UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(share)];
        [self.navigationItem setRightBarButtonItem:shareButton];
    }
    
    //setup the toolbar if needed
    if (self.hideToolbar) {
        
        //setup the webview
        _defaultToolbarHeight = 0.0f;
        [self setupWebView];
        
    } else {
        
        //setup the toolbar and webview
        [self setupToolbar];
        
    }
}

- (void)setupWebView
{
    //setup the webview
    [self setWebView:[[UIWebView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height - _defaultToolbarHeight)]];
    [self.webView setDelegate:self];
    [self.webView setScalesPageToFit:YES];
    [self.webView setUserInteractionEnabled:YES];
    [self.view addSubview:self.webView];
    [self.view sendSubviewToBack:self.webView];
}

- (void)setupToolbar
{
    //get the toolbar image for layout purposes
    UIImage *toolbarImage = [self imageNamed:@"NCBrowserToolbar"];
    _defaultToolbarHeight = toolbarImage.size.height;
    
    //setup the webview
    [self setupWebView];
    
    //setup the toolbar
    [self setToolbar:[[UIView alloc] initWithFrame:CGRectMake(0.0, self.webView.frame.origin.y + self.webView.frame.size.height, self.view.frame.size.width, _defaultToolbarHeight)]];
    [self.toolbar setBackgroundColor:[UIColor colorWithPatternImage:toolbarImage]];
    [self.view addSubview:self.toolbar];
    
    //back button
    UIImage *backImage = [self imageNamed:@"NCBrowserBack"];
    [self setBackButton:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self.backButton setImage:backImage forState:UIControlStateNormal];
    [self.backButton setImage:[self imageNamed:@"NCBrowserBackSelected"] forState:UIControlStateHighlighted];
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar addSubview:self.backButton];
    
    //back button frame
    _toolbarYOffset = round((self.toolbar.frame.size.height - backImage.size.height) / 2);
    
    //forward button
    UIImage *forwardImage = [self imageNamed:@"NCBrowserForward"];
    [self setForwardButton:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self.forwardButton setImage:forwardImage forState:UIControlStateNormal];
    [self.forwardButton setImage:[self imageNamed:@"NCBrowserForwardSelected"] forState:UIControlStateHighlighted];
    [self.forwardButton addTarget:self action:@selector(forward) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbar addSubview:self.forwardButton];
    
    //reload button
    UIImage *reloadImage = [self imageNamed:@"NCBrowserReload"];
    [self setReloadButton:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self.reloadButton setImage:reloadImage forState:UIControlStateNormal];
    [self.reloadButton addTarget:self action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
    [self.reloadButton setImage:[self imageNamed:@"NCBrowserReloadSelected"] forState:UIControlStateHighlighted];
    [self.reloadButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.toolbar addSubview:self.reloadButton];
    
    //stop button
    UIImage *stopImage = [self imageNamed:@"NCBrowserStop"];
    [self setStopButton:[UIButton buttonWithType:UIButtonTypeCustom]];
    [self.stopButton setImage:stopImage forState:UIControlStateNormal];
    [self.stopButton addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [self.stopButton addTarget:self action:@selector(highlightLoadingImage) forControlEvents:UIControlEventTouchDown];
    [self.stopButton addTarget:self action:@selector(highlightLoadingImage) forControlEvents:UIControlEventTouchDragEnter];
    [self.stopButton addTarget:self action:@selector(unhighlightLoadingImage) forControlEvents:UIControlEventTouchDragExit];
    [self.stopButton setImage:[self imageNamed:@"NCBrowserStopSelected"] forState:UIControlStateHighlighted];
    [self.stopButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.stopButton setAlpha:0.0f];
    [self.toolbar addSubview:self.stopButton];
    
    //loading image
    [self setLoadingImage:[[UIImageView alloc] initWithImage:[self imageNamed:@"NCBrowserLoading"]]];
    [self.loadingImage setHighlightedImage:[self imageNamed:@"NCBrowserLoadingSelected"]];
    [self.loadingImage setCenter:CGPointMake(self.stopButton.center.x, self.stopButton.center.y)];
    [self.loadingImage setAlpha:0.0f];
    [self.loadingImage setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
    [self.toolbar insertSubview:self.loadingImage belowSubview:self.stopButton];
    
    //accessibility
    [self.backButton setAccessibilityLabel:@"Back"];
    [self.backButton setAccessibilityHint:@"Moves back one web page"];
    [self.forwardButton setAccessibilityLabel:@"Forward"];
    [self.forwardButton setAccessibilityHint:@"Moves forward one web page"];
    [self.reloadButton setAccessibilityLabel:@"Reload"];
    [self.reloadButton setAccessibilityHint:@"Reloads the current web page"];
    [self.stopButton setAccessibilityLabel:@"Stop"];
    [self.stopButton setAccessibilityHint:@"Stops the currently loading web page"];
}

//returns the proper iphone or ipad image
- (UIImage *)imageNamed:(NSString *)name
{
    //ipad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return [UIImage imageNamed:[NSString stringWithFormat:@"NCWebBrowser.bundle/%@Pad.png", name]];
    }
    
    //iphone
    return [UIImage imageNamed:[NSString stringWithFormat:@"NCWebBrowser.bundle/%@.png", name]];
}

- (void)viewWillAppear:(BOOL)animated
{
    //start the toolbar with the proper size
    [self resizeToolbar:self.interfaceOrientation];
    
    //some buttons shouldn't be enabled yet
    [self updateButtons];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //remove the delegate
    [self.webView setDelegate:nil];
    
    //if we leave this screen, stop loading
    if ([self.webView isLoading]) {
        [self.webView stopLoading];
        [[Utilities instance] stopActivity];
    }
}

- (void)back
{
    [self.webView goBack];
}

- (void)forward
{
    [self.webView goForward];
}

- (void)reload
{
    [self.webView reload];
}

- (void)stop
{
    //stop loading the webview request
    [self.webView stopLoading];
    
    //hide loading state
    [self showLoading:NO];
    
    //un-highlight the loading image
    [self unhighlightLoadingImage];
}

- (void)openSafari
{
    [[UIApplication sharedApplication] openURL:self.webView.request.URL];
}

- (void)openURL:(NSString *)url
{
    //attempt to complete urls that forgot http://
    if (url && [url rangeOfString:@"http"].length == 0 && [url rangeOfString:@":"].length == 0) {
        url = [NSString stringWithFormat:@"http://%@", url];
    }
    
    //clear out the old request
    [self setRequest:nil];
    
    //load the request and start the activity inidicator
    [self setRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]]];
    [self.webView loadRequest:self.request];
    
    //show loading state
    [self showLoading:YES];
}

- (void)close {
    _isLoading = NO;
    [self.webView stopLoading];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadHTMLString:(NSString *)html
{
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSURL *baseURL = [NSURL fileURLWithPath:path];
    [self.webView loadHTMLString:html baseURL:baseURL];
}

- (void)updateButtons
{
    [self.backButton setEnabled:(self.webView.canGoBack) ? YES : NO];
    [self.forwardButton setEnabled:(self.webView.canGoForward) ? YES : NO];
}

#pragma mark - loading

- (void)showLoading:(BOOL)loading
{    
    //start animation block
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.2f];
    
    //show/hide the appropriate buttons & images
    [self.loadingImage setAlpha:loading];
    [self.stopButton setAlpha:loading];
    [self.reloadButton setAlpha:!loading];
    
    //end animation block
    [UIView commitAnimations];
    
    //add or remote the rotation animation
    if (loading) {
        
        //start rotation
        CABasicAnimation *rota = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        [rota setDuration:0.25];
        [rota setAutoreverses:NO];
        [rota setRemovedOnCompletion:NO];
        [rota setRepeatCount:10000];
        [rota setFromValue:[NSNumber numberWithFloat:0]];
        [rota setToValue:[NSNumber numberWithFloat:degreesToRadians(90)]];
        [rota setCumulative:YES];
        [self.loadingImage.layer addAnimation:rota forKey:@"rotation"];
        
    } else {
        
        //stop rotation
        [self.loadingImage.layer removeAllAnimations];
        
    }
}

- (void)highlightLoadingImage
{
    //highlight the loading image
    [self.loadingImage setHighlighted:YES];
}

- (void)unhighlightLoadingImage
{
    //un-highlight the loading image
    [self.loadingImage setHighlighted:NO];
}

#pragma mark - UIWebViewDelegate methods

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{    
    //if there was an error and it is not a cancelled error, show an alert
    if (_isLoading && [error code] != NSURLErrorCancelled) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [errorAlert show];
    }
     
    //not loading anymore
    _isLoading = NO;

    //hide loading state
    [self showLoading:NO];
    [[Utilities instance] stopActivity];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    //we only need to perform the below actions once for each load
    if (_isLoading) {
        return;
    }
    _isLoading = YES;    
    
    //show loading state
    [self showLoading:YES];
    [[Utilities instance] startActivity];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{    
    //no longer loading
    _isLoading = NO;
    
    //update buttons and activity indicators
    [self updateButtons];
    
    //hide loading state
    [self showLoading:NO];
    [[Utilities instance] stopActivity];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)theRequest navigationType:(UIWebViewNavigationType)navigationType
{
    //check to see if we should open this link in a new browser
    if (navigationType == UIWebViewNavigationTypeLinkClicked && self.openLinksInNewBrowser) {
        if (self.navigationController) {
            NCWebBrowser *browser = [[NCWebBrowser alloc] init];
            [browser openURL:theRequest.URL.absoluteString];
            [self.navigationController pushViewController:browser animated:YES];
        }
        return NO;
    }
    return YES;
}

#pragma mark - rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration
{
    [self resizeToolbar:interfaceOrientation];
}

//resize the toolbar based on the orientation to maximize space
- (void)resizeToolbar:(UIInterfaceOrientation)orientation
{
    //determine the height of the toolbar
    float toolbarHeight = _defaultToolbarHeight; //default
    float toolbarScale = 1.0f;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(orientation)) {
        
        //iphone landscape
        toolbarScale = 0.6f;
        toolbarHeight = roundf(toolbarHeight * toolbarScale);
        
    }
    
    //update webview and toolbar frames
    [self.webView setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height - toolbarHeight)];
    [self.toolbar setFrame:CGRectMake(0.0, self.view.frame.size.height - toolbarHeight, self.view.frame.size.width, toolbarHeight)];
    
    //resize the toolbar views
    for (UIView *view in self.toolbar.subviews) {
        
        //get the view's image
        UIImage *image = nil;
        if ([view isKindOfClass:[UIButton class]]) {
            image = [(UIButton *)view imageForState:UIControlStateNormal];
        } else if ([view isKindOfClass:[UIImageView class]]) {
            image = [(UIImageView *)view image];
        }
        
        //resize the view to match the toolbar scale
        [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, roundf(image.size.width * toolbarScale), roundf(image.size.height * toolbarScale))];
    }
    
    //horizontally position toolbar views
    [self.backButton setFrame:CGRectMake(0.0f, _toolbarYOffset, self.backButton.frame.size.width, self.backButton.frame.size.height)];
    [self.forwardButton setFrame:CGRectMake(self.backButton.frame.origin.x + self.backButton.frame.size.width, _toolbarYOffset, self.forwardButton.frame.size.width, self.forwardButton.frame.size.height)];
    [self.reloadButton setFrame:CGRectMake(self.toolbar.frame.size.width - self.reloadButton.frame.size.width, _toolbarYOffset, self.reloadButton.frame.size.width, self.reloadButton.frame.size.height)];
    [self.stopButton setFrame:CGRectMake(self.toolbar.frame.size.width - self.stopButton.frame.size.width, _toolbarYOffset, self.stopButton.frame.size.width, self.stopButton.frame.size.height)];
    [self.loadingImage setCenter:CGPointMake(self.stopButton.center.x, self.stopButton.center.y)];
}

#pragma mark - sharing

//share the current web page
- (void)share
{
    //get the title and url of the current web page
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    NSURL *url = self.webView.request.URL;
    [self shareURL:url withTitle:title];
}

//share a url with a title
- (void)shareURL:(NSURL *)url withTitle:(NSString *)title
{
    if (!url) {
        return;
    }
    
    //setup the activity items
    NSArray *activityItems = nil;
    if (title) {
        activityItems = @[title, url];
    } else {
        activityItems = @[url];
    }
    
    //activities
    TUSafariActivity *safari = [[TUSafariActivity alloc] init];
    NSArray *activities = @[safari];
    
    //show the activity controller
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:activities];
    [self presentViewController:activityController animated:YES completion:nil];
}

@end

@implementation NCWebBrowserNavigationController

- (id)init
{
    self = [super init];
    if (self) {
        
        //add an NCWebBrowser as the only view controller
        [self setBrowser:[[NCWebBrowser alloc] init]];
        [self setViewControllers:@[self.browser]];
        
        //set modal styles
        [self setModalTransitionStyle:self.browser.modalTransitionStyle];
        [self setModalPresentationStyle:self.browser.modalPresentationStyle];
        
        //add a close button
        if (self.browser.navigationItem) {
            UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStylePlain target:self.browser action:@selector(close)];
            [self.browser.navigationItem setLeftBarButtonItem:closeButton];
        }
        
    }
    return self;
}

@end
