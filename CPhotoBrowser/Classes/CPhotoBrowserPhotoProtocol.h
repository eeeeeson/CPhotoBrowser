//
//  CPhotoBrowserPhotoProtocol.h
//  CPhotoBrowser
//
//  Created by eson on 14-5-28.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#ifndef CPhotoBrowser_CPhotoBrowserPhotoProtocol_h
#define CPhotoBrowser_CPhotoBrowserPhotoProtocol_h

typedef void (^CPhotoLoadImageCompletion)();

@protocol CPhotoBrowserPhotoProtocol

- (void)loadImage;

- (void)unloadImage;

@property (nonatomic, strong)UIImage *image;

@property (nonatomic, copy)CPhotoLoadImageCompletion loadImageCompletionBlock;

@end

#endif
