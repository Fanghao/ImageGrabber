//
//  ImageGrabberUtils.m
//  ImageGrabber
//
//  Created by Fanghao Chen on 5/3/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

#import "ImageGrabberUtils.h"

#define SPINNER_TAG 10001

@implementation ImageGrabberUtils

+ (void)startSpinnerInView:(UIView *)view withStyle:(UIActivityIndicatorViewStyle)style {
    if (![view viewWithTag:SPINNER_TAG]) {
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
        activityIndicator.center = view.center;
        activityIndicator.tag = SPINNER_TAG;
        [view addSubview:activityIndicator];
        [activityIndicator startAnimating];
    }
}

+ (void)stopSpinnerInView:(UIView *)view {
    if ([view viewWithTag:SPINNER_TAG]) {
        UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[view viewWithTag:SPINNER_TAG];
        [activityIndicator stopAnimating];
        [activityIndicator removeFromSuperview];
    }
}

+ (void)showAlertView:(NSDictionary *)params {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:[params objectForKey:@"title"]
                          message:[params objectForKey:@"message"]
                          delegate:[params objectForKey:@"delegate"]
                          cancelButtonTitle:[params objectForKey:@"cancelTitle"]
                          otherButtonTitles:[params objectForKey:@"otherTitle"], nil];
    [alert show];
}

@end
