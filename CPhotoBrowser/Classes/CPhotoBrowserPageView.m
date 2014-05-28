//
//  CPhotoBrowserPageView.m
//  CPhotoBrowser
//
//  Created by eson on 14-5-28.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import "CPhotoBrowserPageView.h"

#import "CPhotoBrowser.h"

#import "CPhotoBrowserViewController.h"

@interface CPhotoBrowserPageView ()

@property (nonatomic, strong)UIActivityIndicatorView *activityIndicatorView;

@end

@implementation CPhotoBrowserPageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configScrollView];
        [self buildImageView];
    }
    return self;
}

- (void)configScrollView
{
    self.backgroundColor = [UIColor clearColor];
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)buildImageView
{
	_photoImageView = [[UIImageView alloc]initWithFrame:self.bounds];
	
	UITapGestureRecognizer * singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTapGesture:)];
    [self addGestureRecognizer:singleTap];
	
    UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTapGesture:)];
    doubleTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:doubleTap];
	
    [self addSubview:self.photoImageView];
	
	self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	self.activityIndicatorView.hidesWhenStopped = YES;
	[self addSubview:self.activityIndicatorView];
}

- (void)setPhoto:(id<CPhotoBrowserPhotoProtocol>)photo
{
    self.photoImageView.image = nil;
    _photo = photo;
    [self displayImage];
}

- (void)prepareForReuse
{
    self.photoImageView.image = nil;
    self.zoomScale = 1.0f;
    [self.photo unloadImage];
}

- (void)resetToDefaults
{
    self.zoomScale = self.minimumZoomScale;
}

- (UIImage *)image
{
	return self.photoImageView.image;
}

- (void)displayImage
{
	if (self.photo) {
		self.maximumZoomScale = 1;
		self.minimumZoomScale = 1;
		self.zoomScale = 1;
        
		self.contentSize = CGSizeMake(0, 0);
		
		UIImage *img = [self.photo image];
		if (img) {
			self.photoImageView.image = img;
			self.photoImageView.hidden = NO;
			[self.activityIndicatorView stopAnimating];
			
			CGRect photoImageViewFrame;
			photoImageViewFrame.origin = CGPointZero;
			photoImageViewFrame.size = img.size;
            
			self.photoImageView.frame = photoImageViewFrame;
			self.contentSize = photoImageViewFrame.size;
            
			[self setMaxMinZoomScalesForCurrentBounds];
        } else {
			self.photoImageView.hidden = YES;
			self.activityIndicatorView.hidden = NO ;
			self.activityIndicatorView.center = CGPointMake(0.5 * self.bounds.size.width, 0.5 * self.bounds.size.height);
			[self.activityIndicatorView startAnimating];
        }
        
		[self setNeedsLayout];
	}
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setMaxMinZoomScalesForCurrentBounds];
    [self setNeedsLayout];
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
	self.maximumZoomScale = 1;
	self.minimumZoomScale = 1;
	self.zoomScale = 1;
    
	if (!self.photoImageView.image) {
		return;
	}
    
    CGSize boundsSize = self.bounds.size;
    CGSize imageSize = _photoImageView.frame.size;
    
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    minScale = MIN(minScale, MIN(xScale, yScale));
	
	CGFloat maxScale = 2.5;
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}
    
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;
    
	_photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	} else {
        frameToCenter.origin.x = 0;
	}
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	} else {
        frameToCenter.origin.y = 0;
	}
    
	if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter)) {
		_photoImageView.frame = frameToCenter;
	}
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
	return self.photoImageView;
}

#pragma mark - Tap Detection

- (void)handleSingleTapGesture:(UITapGestureRecognizer *)tap
{
	if ([self.photoBrowser respondsToSelector:@selector(dismissModalViewController)]) {
		[self.photoBrowser performSelector:@selector(dismissModalViewController) withObject:nil afterDelay:0.2];
	}
}

- (void)handleDoubleTapGesture:(UITapGestureRecognizer *)doubleTapGesture
{
	CGPoint touchPoint = [doubleTapGesture locationInView:self];

    [NSObject cancelPreviousPerformRequestsWithTarget:self.photoBrowser selector:@selector(dismissModalViewController) object:nil];
	
	if (self.zoomScale == self.maximumZoomScale) {
		[self setZoomScale:self.minimumZoomScale animated:YES];
	} else {
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
	}
}
@end
