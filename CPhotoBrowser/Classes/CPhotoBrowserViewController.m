//
//  CPhotoBrowserViewController.m
//  CPhotoBrowser
//
//  Created by eson on 14-5-28.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

#import "CPhotoBrowser.h"
#import "CPhotoBrowserPageView.h"

static const CGFloat kPageViewHorizontalGap = 20;

@interface CPhotoBrowserViewController () <UIScrollViewDelegate>
{
    @private
    __weak id <CPhotoBrowserDataSource> _dataSource;
    __weak id <CPhotoBrowserDelegate>   _delegate;
    BOOL                                processingRotationNow;
    NSInteger                           beforeRotationPageIndex;
}
@property (nonatomic, strong) UIScrollView   *pagingScrollView;
@property (nonatomic, strong) NSMutableArray *photos;
@property (nonatomic, strong) NSMutableSet   *recycledPages;
@property (nonatomic, strong) NSMutableSet   *visiblePages;
@property (nonatomic, assign) NSInteger      currentPageIndex;
@property (nonatomic, assign) NSUInteger     indexForResetZoom;

@end

@implementation CPhotoBrowserViewController

- (void)dealloc
{
    self.pagingScrollView.delegate = nil;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self) {
        self.previewImagesToPreload = 1;
		self.currentPageIndex = NSNotFound;
		self.initialIndex = 0;
    }

    return self;
}

#pragma mark - View Life

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self buildPagingScrollView];

    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	if (self.currentPageIndex == NSNotFound) {
		[self showFromIndex:self.initialIndex];
	}
	[self.navigationController setNavigationBarHidden:YES animated:YES];
	[self willAnimateRotationToInterfaceOrientation:self.interfaceOrientation duration:0];
}

#pragma mark -

- (void)buildPagingScrollView
{
    CGRect       pagingScrollViewFrame = [self frameForPagingScrollView];
    UIScrollView *pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];

    self.pagingScrollView = pagingScrollView;

    pagingScrollView.pagingEnabled = YES;
    pagingScrollView.backgroundColor = [UIColor blackColor];
    pagingScrollView.showsVerticalScrollIndicator = NO;
    pagingScrollView.showsHorizontalScrollIndicator = NO;
    pagingScrollView.contentSize = [self contentSizeForPagingScrollView];

    pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    pagingScrollView.delegate = self;

    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:pagingScrollView];

    self.recycledPages = [[NSMutableSet alloc] init];
    self.visiblePages = [[NSMutableSet alloc] init];
}

- (NSMutableArray *)photos
{
    if (!_photos) {
        _photos = [NSMutableArray array];

        if ([self.datasource respondsToSelector:@selector(photosArrayForPhotoBrowser:)]) {
            NSArray *array = [self.datasource photosArrayForPhotoBrowser:self];
            _photos = [NSMutableArray arrayWithArray:array];
        } else {
            NSAssert(NO, @"need implement CPhotoBrowserDataSource");
        }
    }

    return _photos;
}

- (void)showFromIndex:(NSInteger)initialIndex
{
    self.initialIndex = initialIndex;

    [self tilePages];

    CGRect frame = [self frameForPageAtIndex:initialIndex];
    self.pagingScrollView.contentOffset = CGPointMake(frame.origin.x - kPageViewHorizontalGap, 0);
    self.currentPageIndex = initialIndex;

    if (initialIndex == 0) {
        self.currentPageIndex = 0;
        [self didStartViewingPageAtIndex:0];
    }
}

- (void)reloadData
{
    self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    [self tilePages];
}

#pragma mark - Events

- (void)handleSingleTapGesture:(UITapGestureRecognizer *)tap
{
    [self dismissModalViewController];
}

- (void)dismissModalViewController
{
    CPhotoBrowserPopupView *browserPopView = self.browserPopView;
    id <CPhotoBrowserPhotoProtocol> currentPhoto = [self photoAtIndex:self.currentPageIndex];

    BOOL needDismissWithZoomOut = self.initialIndex != self.currentPageIndex;
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self dismissViewControllerAnimated:NO completion:^{ }];

    // will dealloc self
    browserPopView.popupImageView.image = currentPhoto.image;
    browserPopView.popupImageView.frame = [browserPopView centerFrameFromImage:currentPhoto.image];

    if (needDismissWithZoomOut || !browserPopView.senderView.superview) {
        [browserPopView dismissWithZoomOutAnimation];
    } else {
        [browserPopView dismissWithRecoverAnimation];
    }
}

#pragma mark - Tile

- (void)tilePages
{
    if (processingRotationNow) {
        return;
    }

    CGRect     visibleBounds = self.pagingScrollView.bounds;

    NSInteger firstNeededPageIndex = [self limitedPageIndex:floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds))] - (self.previewImagesToPreload);
	firstNeededPageIndex = [self limitedPageIndex:firstNeededPageIndex];

    NSInteger lastNeededPageIndex = [self limitedPageIndex:floorf((CGRectGetMaxX(visibleBounds) - 1) / CGRectGetWidth(visibleBounds))] + (self.previewImagesToPreload);
	lastNeededPageIndex = [self limitedPageIndex:lastNeededPageIndex];
	
    for (CPhotoBrowserPageView *page in self.visiblePages) {
        if ((page.tag < firstNeededPageIndex) || (page.tag > lastNeededPageIndex)) {
            [page prepareForReuse];
            [self.recycledPages addObject:page];
            [page removeFromSuperview];
        }
    }

    [self.visiblePages minusSet:self.recycledPages];
	
	for (NSInteger index = firstNeededPageIndex; index <= lastNeededPageIndex; index ++) {
		[self tilePageViewAtPageIndex:index];
	}
}

- (void)tilePageViewAtPageIndex:(NSUInteger)index
{
    CPhotoBrowserPageView *page = [self visiblePageForIndex:index];

    if (!page) {
        page = [self dequeueRecycledPage];

        if (!page) {
            page = [[CPhotoBrowserPageView alloc] init];
        }

        page.tag = index;
        page.frame = [self frameForPageAtIndex:index];
        page.photoBrowser = self;

        [self.pagingScrollView addSubview:page];
        [self.visiblePages addObject:page];
    }

    id <CPhotoBrowserPhotoProtocol> photo = [self photoAtIndex:index];

    if (page.photo != photo) {
        page.photo = photo;
        __weak CPhotoBrowserPageView *weakPageView = page;
        photo.loadImageCompletionBlock = ^() {
            __strong CPhotoBrowserPageView *strongPageView = weakPageView;
            [strongPageView displayImage];
        };
    }
}

- (CPhotoBrowserPageView *)dequeueRecycledPage
{
    CPhotoBrowserPageView *page = [self.recycledPages anyObject];

    if (page) {
        [self.recycledPages removeObject:page];
    }

    return page;
}

- (CPhotoBrowserPageView *)visiblePageForIndex:(NSUInteger)index
{
    CPhotoBrowserPageView *foundPage = nil;

    for (CPhotoBrowserPageView *page in self.visiblePages) {
        if (page.tag == index) {
            foundPage = page;
            break;
        }
    }

    return foundPage;
}


- (void)didStartViewingPageAtIndex:(NSUInteger)index
{
    [self loadImageForPageIndex:index];
    [self loadPreNexPhotosIfNeed:index];
	if ([self.delegate respondsToSelector:@selector(photoBrowser:didDidStartViewingPageAtIndex:)]) {
		[self.delegate photoBrowser:self didDidStartViewingPageAtIndex:index];
	}
}

- (void)loadPreNexPhotosIfNeed:(NSUInteger)pageIndex
{
    CPhotoBrowserPageView *page = [self visiblePageForIndex:pageIndex];
	
    if (page) {
        if (_currentPageIndex == pageIndex) {
            [self loadImageForPageIndex:pageIndex - 1];
            [self loadImageForPageIndex:pageIndex + 1];
        }
    }
}

- (void)loadImageForPageIndex:(NSInteger)pageIndex
{
    if ((pageIndex < [self numberOfPhotos]) && (pageIndex >= 0)) {
        id <CPhotoBrowserPhotoProtocol> photo = [self photoAtIndex:pageIndex];
		
        if (![photo image]) {
            if ((self.initialIndex == pageIndex) && self.browserPopView.senderView.image) {
                CPhotoBrowserPageView *page = [self visiblePageForIndex:pageIndex];
                photo.image = self.browserPopView.popupImageView.image;
                [page setPhoto:photo];
                photo.image = nil; // temp image is not valid
            }
			
            [photo loadImage];
        }
    }
}


#pragma mark - Page Config

- (CGRect)frameForPagingScrollView
{
    CGRect frame = self.view.bounds;
    frame.origin.x -= kPageViewHorizontalGap;
    frame.size.width += (2 * kPageViewHorizontalGap);
   
	return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index
{
    CGRect bounds = self.pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * kPageViewHorizontalGap);
    pageFrame.origin.x = (bounds.size.width * index) + kPageViewHorizontalGap;
    
	return pageFrame;
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index
{
    return CGPointMake(index * [self frameForPagingScrollView].size.width, 0);
}

- (CGSize)contentSizeForPagingScrollView
{
    CGRect bounds = self.pagingScrollView.bounds;

    return CGSizeMake(bounds.size.width * self.photos.count, bounds.size.height);
}

#pragma mark - Auto Rotate

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    processingRotationNow = YES;
    beforeRotationPageIndex = self.currentPageIndex;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	self.pagingScrollView.frame = [self frameForPagingScrollView];
    self.pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    self.pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:beforeRotationPageIndex];

    for (CPhotoBrowserPageView *page in _visiblePages) {
        page.frame = [self frameForPageAtIndex:page.tag];
    }

    processingRotationNow = NO;

    [self tilePages];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.browserPopView setDestinationStateWhenRotationOrientation];
	[self tilePages];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGRect    visibleBounds = _pagingScrollView.bounds;
    NSInteger index = (NSInteger)(floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
    index = [self limitedPageIndex:index];

    NSUInteger previousCurrentPage = self.currentPageIndex;
    self.currentPageIndex = index;

    if (_currentPageIndex != previousCurrentPage) {
		[self tilePages];
        [self didStartViewingPageAtIndex:index];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.indexForResetZoom = self.currentPageIndex;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;
{
    if (self.indexForResetZoom != self.currentPageIndex) {
        CPhotoBrowserPageView *page = [self visiblePageForIndex:self.indexForResetZoom];
        [page resetToDefaults];
    }

    [self tilePages];
}

#pragma mark - Propertys

- (void)setCurrentPageIndex:(NSInteger)currentPageIndex
{
    _currentPageIndex = currentPageIndex;
}

- (id <CPhotoBrowserPhotoProtocol> )photoAtIndex:(NSUInteger)pageIndex
{
    id <CPhotoBrowserPhotoProtocol> photo = nil;

    if (pageIndex < self.photos.count) {
        photo = [self.photos objectAtIndex:pageIndex];
    }

    return photo;
}

- (NSInteger)numberOfPhotos
{
    return self.photos.count;
}

- (NSInteger)limitedPageIndex:(NSInteger)index
{
	return MIN(MAX(0, index),self.photos.count > 0 ? self.photos.count - 1 : 0);
}

@end
