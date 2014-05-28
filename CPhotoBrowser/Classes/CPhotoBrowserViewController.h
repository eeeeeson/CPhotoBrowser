//
//  CPhotoBrowserViewController.h
//  CPhotoBrowser
//
//  Created by eson on 14-5-28.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CPhotoBrowser.h"

@interface CPhotoBrowserViewController : UIViewController

@property (nonatomic, weak) id <CPhotoBrowserDataSource> datasource;
@property (nonatomic, weak) id <CPhotoBrowserDelegate>   delegate;
@property (nonatomic, assign) NSUInteger                 previewImagesToPreload; // 1 by default
@property (nonatomic, strong) CPhotoBrowserPopupView     *browserPopView;
@property (nonatomic, assign) NSInteger                  initialIndex;

- (void)showFromIndex:(NSInteger)initialIndex;

- (void)dismissModalViewController;

@end
