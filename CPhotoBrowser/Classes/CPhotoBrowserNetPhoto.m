//
//  CPhotoBrowserNetPhoto.m
//  CPhotoBrowser
//
//  Created by eson on 14-5-28.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import "CPhotoBrowserNetPhoto.h"

#import "SDWebImageDownloader.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"

@interface CPhotoBrowserNetPhoto ()

@property (nonatomic, strong)id<SDWebImageOperation> imageDownloaderOperation;
@end

@implementation CPhotoBrowserNetPhoto

- (void)dealloc
{
    [self.imageDownloaderOperation cancel];
}

- (id)init
{
    if (self = [super init]) {
    
	}
    return self;
}

#pragma mark - CPhotoBrowserPhotoProtocol

- (void)loadImage
{
    if (self.photoURL) {
        if (self.image) {
            if (self.loadImageCompletionBlock) {
                self.loadImageCompletionBlock();
            }
        } else {
			UIImage *image = [[SDImageCache sharedImageCache]imageFromDiskCacheForKey:self.photoURL.absoluteString];
			if (image) {
				self.image = image;
				[self imageDidFinishLoad];
			} else {
				[self.imageDownloaderOperation cancel];
				typeof(self)__weak weakSelf = self;
				self.imageDownloaderOperation = [[SDWebImageManager sharedManager]downloadWithURL:self.photoURL
																						  options:SDWebImageRetryFailed
																						 progress:nil
																						completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished) {
																							CPhotoBrowserNetPhoto *strongSelf = weakSelf;
																							if (strongSelf) {
																								strongSelf.image = image;
																								[strongSelf imageDidFinishLoad];
																								[[SDImageCache sharedImageCache]storeImage:image forKey:strongSelf.photoURL.absoluteString];
																							}
																						}];

			}
        }
    }
}

- (void)imageDidFinishLoad
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.loadImageCompletionBlock) {
            self.loadImageCompletionBlock();
        }
    });
}

- (void)unloadImage
{
    self.image = nil;
}
@end
