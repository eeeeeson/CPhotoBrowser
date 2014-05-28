//
//  UIImageView+CPhotoBrowser.h
//  CPhotoBrowser
//
//  Created by eson on 14-5-28.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CPhotoBrowserViewController;

typedef CPhotoBrowserViewController *(^ CPhotoBrowserOpeningBlock)();

@interface CPhotoBrowserTapGesture : UITapGestureRecognizer

@property (nonatomic, copy) CPhotoBrowserOpeningBlock photoBrowserOpeingBlock;

@end

@interface UIImageView (CPhotoBrowser)

- (void)setupPhotoBrowserWithOpeningBlock:(CPhotoBrowserOpeningBlock)openingBlock;

@end

@interface CPhotoBrowserPopupView : UIView

@property (nonatomic, weak) UIImageView   *senderView;
@property (nonatomic, strong) UIView      *blackMaskView;
@property (nonatomic, strong) UIImageView *popupImageView;
@property (nonatomic, weak) UIView        *senderSuperView;
@property (nonatomic, assign) CGRect      originalFrameRelativeToScreen;

- (void)showPopupAnimation:(void (^)(BOOL finished))completion;
- (void)dismissWithRecoverAnimation;
- (void)dismissWithZoomOutAnimation;
- (void)setDestinationStateWhenRotationOrientation;

- (CGRect)centerFrameFromImage:(UIImage *)image;
@end
