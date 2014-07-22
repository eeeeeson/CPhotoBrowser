CPhotoBrowser
===

 a simple photo browser component which compatible with network and local asset library datasource

* access photos from camera roll
* access photos from network
* simply show UIImageView zoom trasition to browser
* support Interface orientation

![Demo](snapshot.gif)

Requirements
---
Xcode5,iOS 5 SDK and Cocoa Pods.

How To Use
---

Setup  browser viewController  associate with UIImageView

```objc
 UIImageView * imageView = [[UIImageView alloc]init];
 [imageView setImageWithURL:initialUrl];
 imageView.contentMode = UIViewContentModeScaleAspectFill;
  __weak typeof(self)weakSelf = self;
 [imageView setupPhotoBrowserWithOpeningBlock:^CPhotoBrowserViewController *{
	CPhotoBrowserViewController *photoBrowserViewController = [[CPhotoBrowserViewController alloc]init];
	photoBrowserViewController.datasource = weakSelf;
	NSInteger index = 0;
	for (CPhotoBrowserNetPhoto * photo in [weakSelf photosArrayForPhotoBrowser:photoBrowserViewController]) {
		if ([photo.photoURL isEqual:initialUrl]) {
			photoBrowserViewController.initialIndex = index;
			break;
		}
		index ++;
	}
	return photoBrowserViewController;
}];
```

Access Local Camera Roll

```objc

#pragma mark - CPhotoBrowserDataSource

- (NSArray *)photosArrayForPhotoBrowser:(CPhotoBrowserViewController *)photoBrowser
{
	for (ALAsset *a in self.assets) {
		CPhotoBrowserAssetPhoto *assetPhoto = [[CPhotoBrowserAssetPhoto alloc]init];
		assetPhoto.asset = a;
		[photos addObject:assetPhoto];
	}
	return photos;
}
```

Access Network Photos

```objc
- (NSArray *)photosArrayForPhotoBrowser:(CPhotoBrowserViewController *)photoBrowser
{
	for (NSString * url in urls) {
		CPhotoBrowserNetPhoto * photo = [[CPhotoBrowserNetPhoto alloc]init];
		photo.photoURL = [NSURL URLWithString:url];
		[photos addObject:photo];
	}
	return photos;
}
```

Very Simple,Hope Helpful
---