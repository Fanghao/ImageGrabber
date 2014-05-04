//
//  ImageGrabberControllerTransition.m
//  ImageGrabber
//
//  Created by Fanghao Chen on 5/3/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

#import "ImageGrabberCollectionViewController.h"
#import "ImageGrabberContentCell.h"
#import "ImageGrabberControllerTransition.h"

@interface ImageGrabberControllerTransition()

@property (nonatomic) TransitionType transitionType;

@end

@implementation ImageGrabberControllerTransition

- (id)initWithType:(TransitionType)type {
    self = [super init];
    if (self) {
        self.transitionType = type;
    }
    return self;
}

# pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.transitionType) {
        case TransitionTypeFade:
            [self setupFadeTransition:transitionContext];
            break;
        default:
            break;
    }
}

# pragma mark - Private Methods

- (void)setupFadeTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // from current VC to Modal VC - fromView has already been in container and add toView when complete
    // from Modal VC to current VC - both fromView (previously toView) and toView (previously fromView) have already been in the container and remove fromView when complete
    UIView *container = transitionContext.containerView;
	
	UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
    ImageGrabberCollectionViewController *collectionVC = nil;
    if ([fromVC isKindOfClass:[ImageGrabberCollectionViewController class]]) {
        collectionVC = (ImageGrabberCollectionViewController *)fromVC;
    } else if ([toVC isKindOfClass:[ImageGrabberCollectionViewController class]]) {
       collectionVC = (ImageGrabberCollectionViewController *)toVC;
    }
    
    NSIndexPath *selected = [collectionVC.imagesCollectionView.indexPathsForSelectedItems firstObject];
    ImageGrabberContentCell *cell = (ImageGrabberContentCell *)[collectionVC.imagesCollectionView cellForItemAtIndexPath:selected];
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    float frameWidth = MIN(screenWidth, collectionVC.targetImageSize.height);
    CGRect centerFrame = CGRectMake((screenWidth - frameWidth) / 2, (screenHeight - frameWidth) / 2, frameWidth, frameWidth);
	CGRect beginFrame = [container convertRect:cell.bounds fromView:cell];
    CGRect endFrame = [transitionContext initialFrameForViewController:fromVC];
    
    // added the screen shots to the desired location
    UIView *moveView = toVC.isBeingPresented ? [toView snapshotViewAfterScreenUpdates:YES] : [fromView snapshotViewAfterScreenUpdates:YES];
    moveView.frame = toVC.isBeingPresented ? beginFrame : fromView.frame;
    moveView.alpha = toVC.isBeingPresented ? 0.0 : 1.0;
    [container addSubview:moveView];
    
    UIView *cellSnapShotView = [cell.contentView snapshotViewAfterScreenUpdates:YES];
    cellSnapShotView.frame = toVC.isBeingPresented ? beginFrame : centerFrame;
    cellSnapShotView.alpha = 1.0 - moveView.alpha;
    [container insertSubview:cellSnapShotView belowSubview:moveView];
    
	[UIView animateWithDuration:0.5 delay:0
         usingSpringWithDamping:800 initialSpringVelocity:15
                        options:0 animations:^{
                            moveView.frame = toVC.isBeingPresented ? endFrame : beginFrame;
                            moveView.alpha = toVC.isBeingPresented ? 1.0 : 0.0;
                            cellSnapShotView.frame = toVC.isBeingPresented ? centerFrame : beginFrame;
                            cellSnapShotView.alpha = 1.0 - moveView.alpha;
                            fromView.hidden = !toVC.isBeingPresented;
                        }
                     completion:^(BOOL finished) {
                         if (toVC.isBeingPresented) {
                             toView.frame = endFrame;
                             [container addSubview:toView];
                         } else {
                             [fromView removeFromSuperview];
                         }
                         [moveView removeFromSuperview];
                         [cellSnapShotView removeFromSuperview];
                         [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
                     }];
}

@end
