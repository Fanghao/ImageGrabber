//
//  ImageGrabberContentCell.m
//  ImageGrabber
//
//  Created by Fanghao Chen on 5/2/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

#import "ImageGrabberContentCell.h"
#import "ImageGrabberUtils.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"

@interface ImageGrabberContentCell()

@property (nonatomic) BOOL isImageCached;

@end

@implementation ImageGrabberContentCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.thumbnailView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.thumbnailView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.thumbnailView];
}

- (void)setupThumbnailViewWithURL:(NSURL *)thumbnailUrl {
    self.thumbnailView.image = nil;
    [self.thumbnailView setImageWithURL:thumbnailUrl placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
}

- (void)startLoadingWithImageURL:(NSURL *)imageUrl {
   self.isImageCached = [[SDWebImageManager sharedManager] diskImageExistsForURL:imageUrl];
    if (!self.isImageCached) {
        [ImageGrabberUtils startSpinnerInView:self.contentView withStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
}

- (void)finishLoading {
    if (!self.isImageCached) {
        [ImageGrabberUtils stopSpinnerInView:self.contentView];
    }
}

@end
