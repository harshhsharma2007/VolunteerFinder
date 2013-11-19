//
//  NCWebBrowser.h
//
//  Created by Brandon Jones.
//  Copyright 2013 nclud, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NCWebBrowser : UIViewController <UIWebViewDelegate>
{
    BOOL _isLoading;
    int _defaultToolbarHeight;
    int _toolbarYOffset;
}

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSURLRequest *request;
@property (strong, nonatomic) UIView *toolbar;
@property (strong, nonatomic) UIButton *backButton;
@property (strong, nonatomic) UIButton *forwardButton;
@property (strong, nonatomic) UIButton *reloadButton;
@property (strong, nonatomic) UIButton *stopButton;
@property (strong, nonatomic) UIImageView *loadingImage;
@property BOOL hideToolbar;
@property BOOL openLinksInNewBrowser;

- (void)back;
- (void)forward;
- (void)reload;
- (void)stop;
- (void)openSafari;
- (void)openURL:(NSString *)url;
- (void)loadHTMLString:(NSString *)html;
- (void)updateButtons;
- (void)close;
- (void)share;
- (void)shareURL:(NSURL *)url withTitle:(NSString *)title;

@end

@interface NCWebBrowserNavigationController : UINavigationController

@property (strong, nonatomic) NCWebBrowser *browser;

@end
