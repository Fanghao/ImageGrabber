//
//  ImageGrabberUtils.h
//  ImageGrabber
//
//  Created by Fanghao Chen on 5/3/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageGrabberUtils : NSObject

+ (void)startSpinnerInView:(UIView *)view withStyle:(UIActivityIndicatorViewStyle)style;
+ (void)stopSpinnerInView:(UIView *)view;
+ (void)showAlertView:(NSDictionary *)params;

@end
