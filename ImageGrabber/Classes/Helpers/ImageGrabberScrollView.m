//
//  ImageGrabberScrollView.m
//  ImageGrabber
//
//  Created by Fanghao Chen on 5/3/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

#import "ImageGrabberScrollView.h"

@interface ImageGrabberScrollView()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CallbackAction callbackAction;

@end

@implementation ImageGrabberScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.minimumZoomScale = 1.0;
        self.maximumZoomScale = 3.0;
        self.zoomScale = self.minimumZoomScale;
        self.contentSize = frame.size;
        self.delegate = self;
        self.backgroundColor = [UIColor clearColor];
        [self addGestures];
    }
    return self;
}

#pragma mark - Public Methods

- (void)setupWithImageView:(UIImageView *)imageView withCallbackAction:(CallbackAction)callbackAction {
    self.imageView = imageView;
    self.imageView.center = self.center;
    self.contentSize = self.imageView.bounds.size;
    [self addSubview:self.imageView];
    if (callbackAction) {
        self.callbackAction = callbackAction;
    }
}

#pragma mark - Gestures

- (void)addGestures {
    // add gestures
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:singleTap];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
    
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    if (self.callbackAction) {
        self.callbackAction();
    }
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
	if (self.zoomScale > self.minimumZoomScale) {
		[self setZoomScale:self.minimumZoomScale animated:YES];
	} else {
		CGPoint location = [recognizer locationInView:[recognizer.view self]];
		CGRect zoomRect = [self zoomRectToPoint:location withScale:self.maximumZoomScale];
		[self zoomToRect:zoomRect animated:YES];
	}
}

- (CGRect)zoomRectToPoint:(CGPoint)zoomPoint withScale:(CGFloat)scale {
    //Normalize current content size back to content scale of 1.0f
    CGSize contentSize;
    contentSize.width = (self.contentSize.width / self.zoomScale);
    contentSize.height = (self.contentSize.height / self.zoomScale);
	
    //translate the zoom point to relative to the content rect
    zoomPoint.x = (zoomPoint.x / self.bounds.size.width) * contentSize.width;
    zoomPoint.y = (zoomPoint.y / self.bounds.size.height) * contentSize.height;
	
    //derive the size of the region to zoom to
    CGSize zoomSize;
    zoomSize.width = self.bounds.size.width / scale;
    zoomSize.height = self.bounds.size.height / scale;
	
    //offset the zoom rect so the actual zoom point is in the middle of the rectangle
    CGRect zoomRect;
    zoomRect.origin.x = zoomPoint.x - zoomSize.width / 2.0f;
    zoomRect.origin.y = zoomPoint.y - zoomSize.height / 2.0f;
    zoomRect.size.width = zoomSize.width;
    zoomRect.size.height = zoomSize.height;
	
	return zoomRect;
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
