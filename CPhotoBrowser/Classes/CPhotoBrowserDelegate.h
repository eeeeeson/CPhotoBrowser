//
//  CPhotoBrowserDelegate.h
//  CPhotoBrowser
//
//  Created by eson on 14-5-28.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#ifndef CPhotoBrowser_CPhotoBrowserDelegate_h
#define CPhotoBrowser_CPhotoBrowserDelegate_h

@class CPhotoBrowserViewController;

@protocol CPhotoBrowserDelegate <NSObject>

@optional

- (void)photoBrowser:(CPhotoBrowserViewController *)photoBrowser didDidStartViewingPageAtIndex:(NSUInteger)pageIndex;

@end

#endif
