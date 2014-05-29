//
//  UIImageView+CPhotoBrowser.m
//  CPhotoBrowser
//
//  Created by eson on 14-5-28.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import "UIImageView+CPhotoBrowser.h"

#import <objc/runtime.h>

#import "CPhotoBrowserViewController.h"

static char gestureRecognizerKey;
static BOOL isPopAnimating = NO;

@implementation UIImageView (PhotoBrowser)

- (void)setupPhotoBrowserWithOpeningBlock:(CPhotoBrowserOpeningBlock)openingBlock
{
    [self removeCurrentTapGesture];

    self.userInteractionEnabled = YES;
    CPhotoBrowserTapGesture *tapGesture = [[CPhotoBrowserTapGesture alloc] initWithTarget:self action:@selector(didTap:)];
    tapGesture.photoBrowserOpeingBlock = openingBlock;

    objc_setAssociatedObject(self, &gestureRecognizerKey, tapGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self addGestureRecognizer:tapGesture];
}

- (void)removeCurrentTapGesture
{
    CPhotoBrowserTapGesture *gesture = objc_getAssociatedObject(self, &gestureRecognizerKey);

    if (gesture) {
        [self removeGestureRecognizer:gesture];
        objc_setAssociatedObject(self, &gestureRecognizerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)didTap:(CPhotoBrowserTapGesture *)tap
{
    if (isPopAnimating) {
        return;
    }

    if (tap.photoBrowserOpeingBlock) {
        CPhotoBrowserViewController *photoViewController = tap.photoBrowserOpeingBlock();
        CPhotoBrowserPopupView      *popup = [[CPhotoBrowserPopupView alloc]init];
        popup.senderView = self;
        photoViewController.browserPopView = popup;
        [popup showPopupAnimation:^(BOOL finished) {
            UIViewController *rootViewController = [[[UIApplication sharedApplication].delegate window]rootViewController];

            if ([rootViewController isKindOfClass:[UINavigationController class]]) {
                [((UINavigationController *)rootViewController).visibleViewController presentViewController : photoViewController animated : NO completion :^{ }];
            } else {
                [rootViewController presentViewController:photoViewController animated:NO completion:^{ }];
            }
        }];
    }
}

@end

#pragma mark -
@implementation CPhotoBrowserTapGesture

@end

#pragma mark -

@implementation CPhotoBrowserPopupView

- (void)dealloc
{
}

- (UIWindow *)keyWindow
{
    return [[UIApplication sharedApplication].delegate window];
}

- (void)buildPopupViews
{
    [self removeFromSuperview];
    [self.keyWindow addSubview:self];
    self.frame = [self keyWindow].bounds;

    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    CGRect           windowBounds = rootViewController.view.bounds;
    self.blackMaskView = [[UIView alloc] initWithFrame:windowBounds];
    self.blackMaskView.backgroundColor = [UIColor blackColor];
    self.blackMaskView.alpha = 0.0f;
    self.blackMaskView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.blackMaskView];

    self.senderSuperView = self.senderView.superview;

    self.originalFrameRelativeToScreen = [self caculateOriginFrameRelativeToScreen];
}

- (CGRect)caculateOriginFrameRelativeToScreen
{
    CGRect newFrame = [self.senderView convertRect:self.senderView.bounds toView:[self keyWindow]];

    newFrame.origin = CGPointMake(newFrame.origin.x, newFrame.origin.y);
    newFrame.size = self.senderView.frame.size;
    return newFrame;
}

- (CGAffineTransform)rotationTransformForPopupImageView
{
    CGAffineTransform   transform = CGAffineTransformIdentity;
    UIDeviceOrientation r = [UIDevice currentDevice].orientation;

    switch (r) {
    case UIDeviceOrientationLandscapeLeft:
        transform = CGAffineTransformMakeRotation(M_PI * 0.5);
        break;

    case UIDeviceOrientationLandscapeRight:
        transform = CGAffineTransformMakeRotation(-M_PI * 0.5);
        break;

    default:
        break;
    }
    return transform;
}

- (void)recoverSenderViewShow
{
    if (self.senderView.hidden) {
        self.senderView.alpha = 0;
        self.senderView.hidden = NO;
    }

    [UIView animateWithDuration:0.3 animations:^{
        self.senderView.alpha = 1;
    }];
}

- (CGSize)imageResizeBaseOnSize:(CGSize)boundsSize imageSize:(CGSize)imageSize
{
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    if (isnan(minScale) || isinf(minScale)) {
        return CGSizeMake(0, 0);
    }

    return CGSizeMake(minScale * imageSize.width, minScale * imageSize.height);
}

+ (UIImage *)imageFromUIView:(UIView *)aView
{
    CGSize pageSize = aView.frame.size;

    UIGraphicsBeginImageContextWithOptions(pageSize, aView.opaque, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [aView.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

#pragma mark - public

- (void)showPopupAnimation:(void (^)(BOOL finished))completion
{
    if (!self.superview) {
        [self buildPopupViews];
    }

    self.popupImageView = [[UIImageView alloc]initWithFrame:self.originalFrameRelativeToScreen];
    self.popupImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.popupImageView.clipsToBounds = YES;
	UIImage *image = self.senderView.image ? self.senderView.image : [[self class] imageFromUIView:self.senderView];
    [self.popupImageView setImage:image];
    self.senderView.hidden = YES;
    [self addSubview:self.popupImageView];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    isPopAnimating = YES;

    [UIView animateWithDuration:0.3 delay:0 options:0 animations:^{
        [self setDestinationStateWhenRotationOrientation];
        self.blackMaskView.alpha = 1;
        self.popupImageView.alpha = 1.0f;
    }   completion:^(BOOL finished) {
        if (finished) {
            if (completion) {
                completion(YES);
            }

            self.popupImageView.userInteractionEnabled = YES;
            self.hidden = YES;

            isPopAnimating = NO;
        }
    }];
}

- (void)dismissWithRecoverAnimation
{
    self.hidden = NO;
    self.blackMaskView.alpha = 1.0f;
    self.popupImageView.clipsToBounds = YES;
    self.originalFrameRelativeToScreen = [self caculateOriginFrameRelativeToScreen];

    if (!self.senderView.image) {
        self.senderView.image = self.popupImageView.image;
    }

    self.popupImageView.image = self.senderView.image;

    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    [UIView animateWithDuration:0.3 delay:0.0f options:0 animations:^{
        self.popupImageView.transform = CGAffineTransformIdentity;
        self.popupImageView.frame = self.originalFrameRelativeToScreen;
        self.blackMaskView.alpha = 0.0f;
    }   completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
            self.senderView.hidden = NO;
        }
    }];
}

- (void)dismissWithZoomOutAnimation
{
    self.hidden = NO;
    self.blackMaskView.alpha = 1;
    self.popupImageView.clipsToBounds = YES;
    self.popupImageView.alpha = 0.6;
    self.senderView.alpha = 0.0f;
    self.senderView.hidden = NO;
    [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.popupImageView.transform = CGAffineTransformMakeScale(2, 2);
        self.popupImageView.alpha = 0.0;
        self.blackMaskView.alpha = 0.0f;
        self.senderView.alpha = 1.0f;
    }   completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

- (void)setDestinationStateWhenRotationOrientation
{
    CGAffineTransform t = [self rotationTransformForPopupImageView];

    self.popupImageView.transform = t;
    CGRect frame = [self centerFrameFromImage:self.popupImageView.image];

    if (!CGAffineTransformEqualToTransform(t, CGAffineTransformIdentity)) {
        CGSize windowSize = [self keyWindow].bounds.size;
        windowSize = CGSizeMake(windowSize.height, windowSize.width);
        CGFloat top = windowSize.height / 2 - frame.size.height / 2;
        CGFloat left = windowSize.width / 2 - frame.size.width / 2;
        self.popupImageView.bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.popupImageView.center = CGPointMake(top + frame.size.height * 0.5, left + frame.size.width * 0.5);
    } else {
        self.popupImageView.frame = frame;
    }
}

- (CGRect)centerFrameFromImage:(UIImage *)image
{
    if (!image || (image.size.height < FLT_MIN) || (image.size.width < FLT_MIN)) {
        return CGRectZero;
    }

    CGSize windowSize = [self keyWindow].bounds.size;

    CGAffineTransform transform = [self rotationTransformForPopupImageView];

    if (!CGAffineTransformEqualToTransform(transform, CGAffineTransformIdentity)) {
        windowSize = CGSizeMake(windowSize.height, windowSize.width);
    }

    CGSize newImageSize = [self imageResizeBaseOnSize:windowSize imageSize:image.size];

    CGFloat top = windowSize.height / 2 - newImageSize.height / 2;
    CGFloat left = windowSize.width / 2 - newImageSize.width / 2;
    CGRect  r = CGRectMake(left, MAX(0, top), newImageSize.width, newImageSize.height);
    return r;
}

@end
