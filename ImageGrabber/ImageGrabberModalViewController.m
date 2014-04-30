//
//  ImageGrabberModalViewController.m
//  ImageGrabber
//
//  Created by Fanghao Chen on 4/28/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

#import <GPUImage/GPUImage.h>
#import "ImageGrabberModalViewController.h"
#import "UIImageView+WebCache.h"

@interface ImageGrabberModalViewController ()

@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UIScrollView *imageScrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *blurImage;

@end

@implementation ImageGrabberModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // add gestures
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self.imageScrollView addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.imageScrollView addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    // setup scroll view
    self.imageScrollView.minimumZoomScale = 1.0;
	self.imageScrollView.maximumZoomScale = 3.0;
	self.imageScrollView.zoomScale = self.imageScrollView.minimumZoomScale;
    self.imageScrollView.contentSize = self.imageView.bounds.size;
    [self.imageScrollView addSubview:self.imageView];
    
    // setup blur view
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.image = self.blurImage;
}

#pragma mark - Gestures

- (void)handleSingleTap:(UIGestureRecognizer *)recognizer {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer {
	if (self.imageScrollView.zoomScale > self.imageScrollView.minimumZoomScale) {
		[self.imageScrollView setZoomScale:self.imageScrollView.minimumZoomScale animated:YES];
	} else {
		CGPoint location = [recognizer locationInView:[recognizer.view self]];
		CGRect zoomRect = [self zoomRectForScrollView:self.imageScrollView ToPoint:location withScale:self.imageScrollView.maximumZoomScale];
		[self.imageScrollView zoomToRect:zoomRect animated:YES];
	}
}

- (CGRect)zoomRectForScrollView:(UIScrollView *)scrollView ToPoint:(CGPoint)zoomPoint withScale:(CGFloat)scale {
    //Normalize current content size back to content scale of 1.0f
    CGSize contentSize;
    contentSize.width = (scrollView.contentSize.width / scrollView.zoomScale);
    contentSize.height = (scrollView.contentSize.height / scrollView.zoomScale);
	
    //translate the zoom point to relative to the content rect
    zoomPoint.x = (zoomPoint.x / scrollView.bounds.size.width) * contentSize.width;
    zoomPoint.y = (zoomPoint.y / scrollView.bounds.size.height) * contentSize.height;
	
    //derive the size of the region to zoom to
    CGSize zoomSize;
    zoomSize.width = scrollView.bounds.size.width / scale;
    zoomSize.height = scrollView.bounds.size.height / scale;
	
    //offset the zoom rect so the actual zoom point is in the middle of the rectangle
    CGRect zoomRect;
    zoomRect.origin.x = zoomPoint.x - zoomSize.width / 2.0f;
    zoomRect.origin.y = zoomPoint.y - zoomSize.height / 2.0f;
    zoomRect.size.width = zoomSize.width;
    zoomRect.size.height = zoomSize.height;
	
	return zoomRect;
}

#pragma mark - Public Methods

- (void)setup:(NSURL *)imageUrl withBlurImage:(UIImage *)imageToBlur withSuccess:(void (^)(CGSize))success withFailure:(void (^)(void))failure {
    __weak ImageGrabberModalViewController *weakSelf = self;
    __block CGSize imageSize = CGSizeZero;
    __block BOOL blurComplete = NO;
    
    self.imageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // call success when blur and get image both finished
    [self applyBlurOnImage:imageToBlur withRadius:1.0f completion:^ {
        blurComplete = YES;
        if (!CGSizeEqualToSize(imageSize, CGSizeZero) && success) {
            success(imageSize);
        }
    }];
    
    [self.imageView setImageWithURL:imageUrl completed: ^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        if (error) {
            if (failure) {
                failure();
            }
        } else {
            imageSize = [weakSelf adjustImageView:image];
            if (blurComplete && success) {
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
    self.imageView.center = self.view.center;
    return self.imageView.frame.size;
}

- (void)applyBlurOnImage:(UIImage *)imageToBlur withRadius:(NSInteger)blurRadius completion:(void (^)(void))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
        GPUImageiOSBlurFilter *blurFilter = [[GPUImageiOSBlurFilter alloc] init];
        blurFilter.blurRadiusInPixels = blurRadius;
        self.blurImage = [blurFilter imageByFilteringImage:imageToBlur];
        dispatch_sync(dispatch_get_main_queue(), ^{
            self.backgroundImageView.image = self.blurImage;
            if (completion) {
                completion();
            }
        });
    });
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents:scrollView];
}

- (void)centerScrollViewContents:(UIScrollView *)scrollView {
    CGSize boundsSize = scrollView.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

@end
