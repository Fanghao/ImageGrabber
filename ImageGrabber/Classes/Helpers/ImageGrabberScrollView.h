//
//  ImageGrabberScrollView.h
//  ImageGrabber
//
//  Created by Fanghao Chen on 5/3/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CallbackAction)();

@interface ImageGrabberScrollView : UIScrollView <UIScrollViewDelegate>

- (void)setupWithImageView:(UIImageView *)imageView withCallbackAction:(CallbackAction)callbackAction;

@end
