//
//  ImageGrabberModalViewController.h
//  ImageGrabber
//
//  Created by Fanghao Chen on 4/28/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

@interface ImageGrabberModalViewController : UIViewController

- (void)setup:(NSURL *)imageUrl withSuccess:(void (^)(CGSize))success withFailure:(void (^)(void))failure;

@end
