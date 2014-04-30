//
//  ImageGrabberViewController.m
//  ImageGrabber
//
//  Created by Fanghao Chen on 4/28/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "ImageGrabberModalViewController.h"
#import "ImageGrabberViewController.h"
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"

// modify/create/delete correspoinding string values for other image search APIs
NSString *const API_KEY = @"AIzaSyBP7Seoet_T16edekw0_CHOiTk3WUBuEcw";
NSString *const SEARCH_ENGINE_ID = @"018000704468456094845:xnu-_vrieqq";
NSString *const PARTIAL_SEARCH_FIELDS = @"fields=items(pagemap/cse_image/src,pagemap/cse_thumbnail/src)";
NSString *const URL_STRING = @"https://www.googleapis.com/customsearch/v1?key=%@&cx=%@&%@&q=%@";
NSString *const THUMBNAIL_PATH = @"pagemap.cse_thumbnail.src";
NSString *const IMAGE_PATH = @"pagemap.cse_image.src";

@interface ImageGrabberViewController ()

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UICollectionView *imagesCollectionView;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *thumbnailUrls;
@property (nonatomic) CGSize targetImageSize;

@end

@implementation ImageGrabberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activityIndicator = nil;
    self.descriptionLabel.hidden = YES;
    self.items = [NSMutableArray array];
    self.thumbnailUrls = [NSMutableArray array];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    NSIndexPath *selected = [self.imagesCollectionView.indexPathsForSelectedItems firstObject];
	UICollectionViewCell *cell = [self.imagesCollectionView cellForItemAtIndexPath:selected];
	
    // from current VC to Modal VC - fromView has already been in container and add toView when complete
    // from Modal VC to current VC - both fromView (previously toView) and toView (previously fromView) have already been in the container and remove fromView when complete
    UIView *container = transitionContext.containerView;
	
	UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    float frameWidth = MIN(screenWidth, self.targetImageSize.height);
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

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbnailUrls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    for (UIView *subview in cell.contentView.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)subview;
            imageView.image = nil;
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            // If you wish to use non-cache image, use AFNetworking.
            [imageView setImageWithURL:self.thumbnailUrls[indexPath.row]];
            break;
        }
    }
////    TODO: Load More if searching has done
//    if (indexPath.item == self.itthumbnailUrls.count) {
//    }
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    UIImage *imageToBlur = nil;
    for (UIView *subview in selectedCell.contentView.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            UIImageView *imageView = (UIImageView *)subview;
            imageToBlur = imageView.image;
            break;
        }
    }
    NSDictionary *selectedDict = self.items[indexPath.row];
    NSURL *imageUrl = [NSURL URLWithString:[[selectedDict valueForKeyPath:IMAGE_PATH] firstObject]];
    BOOL isCached = [[SDWebImageManager sharedManager] diskImageExistsForURL:imageUrl];
    if (!isCached) {
        [self startSpinnerInView:selectedCell.contentView withStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    ImageGrabberModalViewController *imageModalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"imageModalVC"];
    __weak ImageGrabberViewController *weakSelf = self;
    
    void(^successBlock)(CGSize) = ^void(CGSize imageSize) {
        imageModalVC.transitioningDelegate = self;
        imageModalVC.modalPresentationStyle = UIModalPresentationCustom;
        weakSelf.targetImageSize = imageSize;
        [weakSelf stopSpinner];
        [weakSelf presentViewController:imageModalVC animated:YES completion:nil];
    };
    
    void(^failureBlock)(void) = ^void(void) {
        [weakSelf displayFailMessage];
    };
    
    if (!imageUrl || !imageToBlur) {
        [self displayFailMessage];
    } else {
        [imageModalVC setup:imageUrl withBlurImage:imageToBlur withSuccess:successBlock withFailure:failureBlock];
    }
}

# pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self startSpinnerInView:self.view withStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self fetchData:searchBar.text];
}

#pragma mark - Private Methods

- (void)startSpinnerInView:(UIView *)view withStyle:(UIActivityIndicatorViewStyle)style {
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];
    self.activityIndicator.center = view.center;
    [view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

- (void)stopSpinner {
    if (self.activityIndicator) {
        [self.activityIndicator stopAnimating];
        [self.activityIndicator removeFromSuperview];
        self.activityIndicator = nil;
    }
}

- (void)displayFailMessage {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error!"
                          message:@"Failed to get the image."
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    [alert show];
    [self stopSpinner];
    [self.imagesCollectionView reloadData];
}

- (void)fetchData:(NSString *)searchString {
    __weak ImageGrabberViewController *weakSelf = self;
    NSString *urlString = [NSString stringWithFormat:URL_STRING, API_KEY, SEARCH_ENGINE_ID, PARTIAL_SEARCH_FIELDS, searchString];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // send to a background queue since AFNetworking completion block will call main queue
    void(^completionBlock)(id) = ^void(id responseObject) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul), ^{
            [weakSelf parseJSON:(NSDictionary *)responseObject];
            dispatch_sync(dispatch_get_main_queue(), ^{
                weakSelf.descriptionLabel.hidden = (self.thumbnailUrls.count != 0);
                [weakSelf stopSpinner];
                [weakSelf.imagesCollectionView reloadData];
            });
        });
    };
    
    void(^failureBlock)(void) = ^void(void) {
        [weakSelf displayFailMessage];
    };
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (!operation.isCancelled) {
            failureBlock();
        }
    }];
    [operation start];
}

- (void)parseJSON:(NSDictionary *)json {
    self.items = [json objectForKey:@"items"];
    [self.thumbnailUrls removeAllObjects];
    for (NSDictionary *itemDict in self.items) {
        NSURL *thumbnailUrl = (NSURL *)[[itemDict valueForKeyPath:THUMBNAIL_PATH] firstObject];
        [self.thumbnailUrls addObject:thumbnailUrl];
    }
}

@end
