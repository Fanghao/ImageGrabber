//
//  ImageGrabberCollectionViewController.m
//  ImageGrabber
//
//  Created by Fanghao Chen on 4/28/14.
//  Copyright (c) 2014 Fanghao Chen. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "ImageGrabberContentCell.h"
#import "ImageGrabberCollectionViewController.h"
#import "ImageGrabberControllerTransition.h"
#import "ImageGrabberModalViewController.h"
#import "ImageGrabberUtils.h"

#define IMAGES_LIMIT 20

// modify/create/delete correspoinding string values for other image search APIs
NSString *const API_KEY = @"AIzaSyBP7Seoet_T16edekw0_CHOiTk3WUBuEcw";
NSString *const SEARCH_ENGINE_ID = @"00326035433305777517:zwlu3phcgco";
NSString *const ADDITIONAL_SEARCH_PARAM = @"searchType=image&imgSize=xlarge";
NSString *const URL_STRING = @"https://www.googleapis.com/customsearch/v1?key=%@&cx=%@&q=%@&%@&start=%d";

@interface ImageGrabberCollectionViewController ()

@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *thumbnailUrls;
@property (nonatomic) int startIndex;

@end

@implementation ImageGrabberCollectionViewController

#pragma mark - Overwritten Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    self.activityIndicator = nil;
    self.descriptionLabel.hidden = YES;
    self.startIndex = 1;
    self.items = [NSMutableArray array];
    self.thumbnailUrls = [NSMutableArray array];
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                  presentingController:(UIViewController *)presenting
                                                                      sourceController:(UIViewController *)source {
    return [[ImageGrabberControllerTransition alloc] initWithType:TransitionTypeFade];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[ImageGrabberControllerTransition alloc] initWithType:TransitionTypeFade];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.thumbnailUrls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageGrabberContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    [cell setupThumbnailViewWithURL:self.thumbnailUrls[indexPath.row]];
    // Load more
    if (indexPath.row == self.thumbnailUrls.count - 1 && self.thumbnailUrls.count <= IMAGES_LIMIT && self.startIndex > 0 ) {
        [self fetchData:self.searchBar.text];
    }
    return cell;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.searchBar resignFirstResponder];
    NSDictionary *selectedDict = self.items[indexPath.row];
    NSURL *imageUrl = [NSURL URLWithString:(NSString *)[selectedDict objectForKey:@"link"]];
    ImageGrabberContentCell *selectedCell = (ImageGrabberContentCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [selectedCell startLoadingWithImageURL:imageUrl];
    
    ImageGrabberModalViewController *imageModalVC = [self.storyboard instantiateViewControllerWithIdentifier:@"imageModalVC"];
    __weak ImageGrabberContentCell *weakCell = selectedCell;
    __weak ImageGrabberCollectionViewController *weakSelf = self;

    void(^successBlock)(CGSize) = ^void(CGSize imageSize) {
        imageModalVC.transitioningDelegate = self;
        imageModalVC.modalPresentationStyle = UIModalPresentationCustom;
        weakSelf.targetImageSize = imageSize;
        [weakSelf presentViewController:imageModalVC animated:YES completion:nil];
        [weakCell finishLoading];
    };
    
    void(^failureBlock)(void) = ^void(void) {
        [weakSelf displayFailMessage];
    };
    
    if (!imageUrl) {
        [self displayFailMessage];
    } else {
        [imageModalVC setup:imageUrl withSuccess:successBlock withFailure:failureBlock];
    }
}

# pragma mark - UISearchBar Delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self resetResults];
    [self fetchData:searchBar.text];
}

#pragma mark - Private Methods

- (void)startSpinner {
    [ImageGrabberUtils startSpinnerInView:self.view withStyle:UIActivityIndicatorViewStyleWhiteLarge];
}

- (void)stopSpinner {
    [ImageGrabberUtils stopSpinnerInView:self.view];
}

- (void)displayFailMessage {
    NSDictionary *params = [[NSDictionary alloc] initWithObjects:@[@"Error!", @"Failed to get the image.", self, @"OK"] forKeys:@[@"title", @"message", @"delegate", @"cancelTitle"]];
    [ImageGrabberUtils showAlertView:params];
    [self stopSpinner];
}

- (void)resetResults {
    self.startIndex = 1;
    [self.items removeAllObjects];
    [self.thumbnailUrls removeAllObjects];
}

- (void)fetchData:(NSString *)searchString {
    [self startSpinner];
    NSString *urlString = [NSString stringWithFormat:URL_STRING, API_KEY, SEARCH_ENGINE_ID, searchString, ADDITIONAL_SEARCH_PARAM, self.startIndex];
    urlString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // send to a background queue since AFNetworking completion block will call main queue
    __weak ImageGrabberCollectionViewController *weakSelf = self;
    
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
    if ([json valueForKeyPath:@"queries.nextPage.startIndex"]) {
        self.startIndex = [[[json valueForKeyPath:@"queries.nextPage.startIndex"] firstObject] intValue];
    } else {
        self.startIndex = 0;
    }
    NSArray *newArray = [json objectForKey:@"items"];
    [self.items addObjectsFromArray:newArray];
    for (NSDictionary *itemDict in newArray) {
        NSURL *thumbnailUrl = [NSURL URLWithString:(NSString *)[[itemDict objectForKey:@"image"] objectForKey:@"thumbnailLink"]];
        [self.thumbnailUrls addObject:thumbnailUrl];
    }
}

@end
