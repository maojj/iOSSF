//
//  SFLoginViewController.m
//  SegmentFault
//
//  Created by jiajun on 12/13/12.
//  Copyright (c) 2012 SegmentFault.com. All rights reserved.
//

#import "SFLoginService.h"
#import "SFLoginViewController.h"

@interface SFLoginViewController ()

@end

@implementation SFLoginViewController

#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self reloadToolBar];
    self.webView.alpha = 0.0f;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{    
    NSMutableDictionary *loginInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"400", @"status", nil];
    NSHTTPCookie *cookie;
    for (cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([@"sfuid" isEqualToString:cookie.name] && 0 < cookie.value.length) {
            [loginInfo setValue:cookie.value forKey:@"sfuid"];
            [loginInfo setValue:@"0" forKey:@"status"];
        }
        else if ([@"sfsess" isEqualToString:cookie.name]) {
            [loginInfo setValue:cookie.value forKey:@"sfsess"];
        }
    }
    
    if (loginInfo && 0 == [[loginInfo objectForKey:@"status"] intValue]) {
        if ([SFLoginService loginWithInfo:loginInfo]) {
            if (nil != [self.params objectForKey:@"callback"]) {
                __weak UMViewController *lastViewController = [self.navigator.viewControllers objectAtIndex:(self.navigator.viewControllers.count - 2)];
                SEL callback = NSSelectorFromString([self.params objectForKey:@"callback"]);
                if (lastViewController && callback && [lastViewController respondsToSelector:callback]) {
                    [lastViewController performSelector:callback withObject:nil afterDelay:0.5f];
                }
            }
            [self.navigator popViewControllerAnimated:YES];
        }
        else {
            [SFLoginService logout];
            [self loadRequest];
            self.webView.alpha = 1.0f;
        }
    }
    else {
        self.webView.alpha = 1.0f;
    }
    [super webViewDidFinishLoad:webView];
}

#pragma mark

- (void)viewDidLoad
{
    self.url = [NSURL URLWithString:@"http://segmentfault.com/user/login"];
    [super viewDidLoad];
    
    self.webView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.webView.multipleTouchEnabled = NO;
    self.webView.scalesPageToFit = NO;
    self.webView.delegate = self;
    self.webView.autoresizesSubviews = YES;
}

@end
