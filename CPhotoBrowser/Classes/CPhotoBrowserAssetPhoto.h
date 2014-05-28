//
//  CPhotoBrowserAssetPhoto.h
//  CPhotoBrowser
//
//  Created by eson on 14-5-28.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AssetsLibrary/AssetsLibrary.h>
#import "CPhotoBrowser.h"

@interface CPhotoBrowserAssetPhoto : NSObject<CPhotoBrowserPhotoProtocol>

@property (nonatomic, strong)ALAsset *asset;
@property (nonatomic, strong)UIImage *image;
@property (nonatomic, copy)CPhotoLoadImageCompletion loadImageCompletionBlock;

@end