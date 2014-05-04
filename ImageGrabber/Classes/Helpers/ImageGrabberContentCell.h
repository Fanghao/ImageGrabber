//
//  ImageGrabberContentCell.h
//  ImageGrabber
//
//  Created by Fanghao Chen on 5/2/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageGrabberContentCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *thumbnailView;

- (void)setupThumbnailViewWithURL:(NSURL *)thumbnailUrl;
- (void)startLoadingWithImageURL:(NSURL *)imageUrl;
- (void)finishLoading;

@end
