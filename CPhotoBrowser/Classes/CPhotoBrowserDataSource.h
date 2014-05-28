//
//  CPhotoBrowserDataSource.h
//  CPhotoBrowser
//
//  Created by eson on 14-5-28.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#ifndef CPhotoBrowser_CPhotoBrowserDataSource_h
#define CPhotoBrowser_CPhotoBrowserDataSource_h

@class CPhotoBrowserViewController;

@protocol CPhotoBrowserDataSource <NSObject>

- (NSArray *)photosArrayForPhotoBrowser:(CPhotoBrowserViewController *)photoBrowser;

@end

#endif
