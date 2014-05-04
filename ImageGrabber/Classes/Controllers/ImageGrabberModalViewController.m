//
//  ImageGrabberModalViewController.m
//  ImageGrabber
//
//  Created by Fanghao Chen on 4/28/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

#import "ImageGrabberModalViewController.h"
#import "ImageGrabberScrollView.h"
#import "UIImageView+WebCache.h"
#import "UIImage+ImageEffects.h"

@interface ImageGrabberModalViewController ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *blurImage;

@end

@implementation ImageGrabberModalViewController

#pragma mark - Overwritten Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // setup background view
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundImageView.image = self.blurImage;
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.alpha = 1.0;
    [self.view addSubview:self.backgroundImageView];
    
    // setup scroll view
    __weak ImageGrabberModalViewController *weakSelf = self;
    ImageGrabberScrollView *imageScrollView = [[ImageGrabberScrollView alloc] initWithFrame:self.view.bounds];
    [imageScrollView setupWithImageView:self.imageView withCallbackAction:^ {
        [weakSelf dismissViewControllerAnimated:YES completion:nil];
    }];
    [self.view addSubview:imageScrollView];
}

#pragma mark - Public Methods

- (void)setup:(NSURL *)imageUrl withSuccess:(void (^)(CGSize))success withFailure:(void (^)(void))failure {
    __block CGSize imageSize = CGSizeZero;
    __weak ImageGrabberModalViewController *weakSelf = self;

    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    // call success when blur and get image both finished
    [self.imageView setImageWithURL:imageUrl completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (error) {
            if (failure) {
                failure();
            }
        } else {
            weakSelf.blurImage = [image applyBlurWithRadius:8.0 tintColor:nil saturationDeltaFactor:1.0 maskImage:nil];
            imageSize = [weakSelf adjustImageView:image];
            if (success) {
                success(imageSize);
            }
        }
    }];
}

#pragma mark - Private Methods

- (CGSize)adjustImageView:(UIImage *)image {
    int screenWidth = [UIScreen mainScreen].bounds.size.width;
    float ratio = (float)screenWidth / image.size.width;
    self.imageView.frame = CGRectMake(0, 0, screenWidth, image.size.height * ratio);
    return self.imageView.frame.size;
}

@end
