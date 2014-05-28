//
//  CPhotoBrowserAssetPhoto.m
//  CPhotoBrowser
//
//  Created by eson on 14-5-28.
//  Copyright (c) 2014年 eson. All rights reserved.
//

#import "CPhotoBrowserAssetPhoto.h"


@implementation CPhotoBrowserAssetPhoto

- (void)loadImage
{
	if (self.image) {
		[self imageDidFinishLoad];
	} else {
		[self cancelLoadingImage];
		[self performSelectorInBackground:@selector(loadAspectRatioThumbnail) withObject:nil];
	}
}

- (void)cancelLoadingImage
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector: @selector(loadAspectRatioThumbnail) object:nil];
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector: @selector(loadFullResolutionImage) object:nil];
}

- (void)loadAspectRatioThumbnail
{
	@autoreleasepool {
		self.image = [UIImage imageWithCGImage:[self.asset aspectRatioThumbnail]];
		[self imageDidFinishLoad];
		[self performSelectorInBackground:@selector(loadFullResolutionImage) withObject:nil];
	}
}

- (void)loadFullResolutionImage
{
	@autoreleasepool {
		ALAssetRepresentation* defaultRepresentation = [self.asset defaultRepresentation];
		self.image = [UIImage imageWithCGImage:[defaultRepresentation fullResolutionImage]
										 scale:defaultRepresentation.scale
								   orientation:(UIImageOrientation)defaultRepresentation.orientation];
		[self imageDidFinishLoad];
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
	@autoreleasepool {
		[self cancelLoadingImage];
		self.image = nil;
	}
}

@end
