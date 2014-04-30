//
//  ImageGrabberViewController.h
//  ImageGrabber
//
//  Created by Fanghao Chen on 4/28/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const API_KEY;
extern NSString *const SEARCH_ENGINE_ID;
extern NSString *const PARTIAL_SEARCH_FIELDS;
extern NSString *const URL_STRING;
extern NSString *const THUMBNAIL_PATH;
extern NSString *const IMAGE_PATH;

@interface ImageGrabberViewController : UIViewController <UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UIAlertViewDelegate>

@end
