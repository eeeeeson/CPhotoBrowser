//
//  CPhotoBrowserNetPhoto.h
//  CPhotoBrowser
//
//  Created by eson on 14-5-28.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CPhotoBrowserPhotoProtocol.h"

@interface CPhotoBrowserNetPhoto : NSObject

@property (nonatomic, copy)NSURL *photoURL;
@property (nonatomic, strong)UIImage *image;
@property (nonatomic, copy)CPhotoLoadImageCompletion loadImageCompletionBlock;

@end
