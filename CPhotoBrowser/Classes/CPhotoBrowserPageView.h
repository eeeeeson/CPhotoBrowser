//
//  CPhotoBrowserPageView.h
//  CPhotoBrowser
//
//  Created by eson on 14-5-28.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CPhotoBrowser.h"

@class CPhotoBrowserViewController;

@interface CPhotoBrowserPageView : UIScrollView <UIScrollViewDelegate>

@property (nonatomic, strong, readonly)UIImageView *photoImageView;
@property (nonatomic, strong)id<CPhotoBrowserPhotoProtocol>photo;
@property (nonatomic, weak)CPhotoBrowserViewController *photoBrowser;

- (UIImage *)image;

- (void)displayImage;
- (void)prepareForReuse;
- (void)resetToDefaults;

@end
