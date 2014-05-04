//
//  ImageGrabberCollectionViewController.h
//  ImageGrabber
//
//  Created by Fanghao Chen on 4/28/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

extern NSString *const API_KEY;
extern NSString *const SEARCH_ENGINE_ID;
extern NSString *const ADDITIONAL_SEARCH_PARAM;
extern NSString *const URL_STRING;

@interface ImageGrabberCollectionViewController : UIViewController <UIViewControllerTransitioningDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UICollectionView *imagesCollectionView;
@property (nonatomic) CGSize targetImageSize;

@end
