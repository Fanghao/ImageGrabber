//
//  ImageGrabberModalViewController.h
//  ImageGrabber
//
//  Created by Fanghao Chen on 4/28/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageGrabberModalViewController : UIViewController <UIScrollViewDelegate, UIAlertViewDelegate>

- (void)setup:(NSURL *)imageUrl withBlurImage:(UIImage *)imageToBlur withSuccess:(void (^)(CGSize))success withFailure:(void (^)(void))failure;

@end
