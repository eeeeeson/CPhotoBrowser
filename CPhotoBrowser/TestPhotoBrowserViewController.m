
#import "TestPhotoBrowserViewController.h"

#import <AssetsLibrary/AssetsLibrary.h>

#import "CPhotoBrowser.h"

typedef NS_ENUM(NSInteger, CPhotoLoadSourceType) {
	CPhotoLoadSourceTypeLocalAssets,
	CPhotoLoadSourceTypeNetwork,
};

@interface TestPhotoBrowserViewController ()
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, assign) CPhotoLoadSourceType sourceType;
@end

@implementation TestPhotoBrowserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];

//    UIImageView * imageView = [[UIImageView alloc]init];
//    [imageView setImageWithURL:[NSURL URLWithString:@"http://a.hiphotos.baidu.com/album/w%3D2048/sign=bb86f9319213b07ebdbd570838ef9023/e61190ef76c6a7ef8e6fd636fcfaaf51f3de6650.jpg"]];
//    imageView.contentMode = UIViewContentModeScaleAspectFill;
//    
//    __weak typeof(self)weakSelf = self;
//    [imageView setupPhotoBrowserWithOpeningBlock:^CPhotoBrowserViewController *{
//        CPhotoBrowserViewController *photoBrowserViewController = [[CPhotoBrowserViewController alloc]init];
//        photoBrowserViewController.datasource = weakSelf;
//        photoBrowserViewController.initialIndex = 2;
//		weakSelf.sourceType = CPhotoLoadSourceTypeNetwork;
//        return photoBrowserViewController;
//    }];
//    [self.view addSubview:imageView];
//    imageView.clipsToBounds = YES;
//    imageView.frame = CGRectMake(40, 80, 250,400);
	
	UIButton *loadAssetButton = [UIButton buttonWithType:UIButtonTypeCustom];
	[loadAssetButton setTitle:@"图库" forState:UIControlStateNormal];
	loadAssetButton.backgroundColor = [UIColor redColor];
	loadAssetButton.frame = CGRectMake(120, 20, 80, 40);
	[loadAssetButton addTarget:self action:@selector(loadLocalAssetGroup) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:loadAssetButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadLocalAssetGroup
{
	if (!self.assetsLibrary) {
		self.assetsLibrary =  [[ALAssetsLibrary alloc]init];
	}
	self.assets = [NSMutableArray array];
	[self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
		[group setAssetsFilter:[ALAssetsFilter allPhotos]];
		if (group.numberOfAssets) {
			[self loadAssets:group];
			*stop = YES;
		}
	} failureBlock:^(NSError *error) {

	}];
}

- (void)loadAssets:(ALAssetsGroup *)assetsGroup
{
	self.assets = [NSMutableArray array];
	[assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
	[assetsGroup enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
		if (result) {
			NSLog(@"asset %@",result);
			[self.assets addObject:result];
		} else {
			[self showAssetsPhotoBrowser];
			*stop = YES;
		}
	}];
}

- (void)showAssetsPhotoBrowser
{
	self.sourceType = CPhotoLoadSourceTypeLocalAssets;
	CPhotoBrowserViewController *photoBrowserViewController = [[CPhotoBrowserViewController alloc]init];
	photoBrowserViewController.datasource = self;
	[self presentViewController:photoBrowserViewController animated:YES completion:nil];
}

#pragma mark - CPhotoBrowserDataSource

- (NSArray *)photosArrayForPhotoBrowser:(CPhotoBrowserViewController *)photoBrowser
{
	NSMutableArray * photos = [NSMutableArray array];
	if (self.sourceType == CPhotoLoadSourceTypeLocalAssets) {
		for (ALAsset *a in self.assets) {
			CPhotoBrowserAssetPhoto *assetPhoto = [[CPhotoBrowserAssetPhoto alloc]init];
			assetPhoto.asset = a;
			[photos addObject:assetPhoto];
		}
	} else {
//		NSArray * urls = @[@"http://h.hiphotos.bdimg.com/album/s%3D1100%3Bq%3D90/sign=017c5d50d309b3deefbfe069fc8f57f0/63d9f2d3572c11dffede451b612762d0f703c2ff.jpg",
//						   @"http://g.hiphotos.bdimg.com/album/s%3D1100%3Bq%3D90/sign=56a11e4baf4bd11300cdb3336a9f9f7e/a044ad345982b2b74e96c3fc33adcbef76099bf9.jpg",
//						   @"http://d.hiphotos.baidu.com/album/w%3D2048/sign=8311d6d0be3eb13544c7b0bb9226a8d3/a5c27d1ed21b0ef418ce6266dfc451da81cb3ee7.jpg",
//						   @"http://e.hiphotos.baidu.com/album/w%3D2048/sign=c67250cf2f738bd4c421b53195b386d6/3c6d55fbb2fb431671e4556821a4462309f7d32c.jpg",
//						   @"http://c.hiphotos.bdimg.com/album/s%3D1100%3Bq%3D90/sign=9e1ca10e1f950a7b71354ac53ae159a8/48540923dd54564e404c1e01b1de9c82d1584fd9.jpg",
//						   @"http://f.hiphotos.baidu.com/album/w%3D2048/sign=9f47cd1db27eca8012053ee7a51b96dd/91ef76c6a7efce1bb040a3f4ad51f3deb48f65a0.jpg",
//						   @"http://g.hiphotos.baidu.com/album/w%3D2048/sign=685b55673c6d55fbc5c67126591a4e4a/14ce36d3d539b600743f360ee850352ac75cb791.jpg",
//						   @"http://h.hiphotos.bdimg.com/album/s%3D1100%3Bq%3D90/sign=0e178598f403738dda4a0823832b8b20/4ec2d5628535e5dd50075fe774c6a7efce1b62db.jpg",
//						   @"http://e.hiphotos.baidu.com/album/w%3D2048/sign=3be6caa7c9fcc3ceb4c0ce33a67dd488/d01373f082025aafd8f9384efaedab64024f1a6f.jpg",
//						   @"http://f.hiphotos.baidu.com/album/w%3D2048/sign=4e3f9bafcefc1e17fdbf8b317ea8f703/0bd162d9f2d3572c1c49b0658b13632763d0c3db.jpg",
//						   @"http://f.hiphotos.bdimg.com/album/s%3D1100%3Bq%3D90/sign=1829f8dbd739b60049ce0bb6d9600e5b/38dbb6fd5266d01604c36510952bd40735fa352b.jpg",
//						   @"http://a.hiphotos.baidu.com/album/w%3D2048/sign=09b7ad07962bd40742c7d4fd4fb19f51/4b90f603738da9773981b504b151f8198618e376.jpg",
//						   @"http://b.hiphotos.bdimg.com/album/s%3D800%3Bq%3D90/sign=1848ebb9b21bb0518b24be280641ab89/37d12f2eb9389b50fefd07c98435e5dde7116e2f.jpg",
//						   @"http://b.hiphotos.baidu.com/album/w%3D230/sign=06d73d85472309f7e76faa11420f0c39/b3119313b07eca802ca511f6902397dda144837a.jpg",
//						   @"http://g.hiphotos.bdimg.com/album/s%3D1100%3Bq%3D90/sign=12325f2b95dda144de0968b38287ebd3/d043ad4bd11373f09ce794a7a60f4bfbfbed0429.jpg",
//						   @"http://a.hiphotos.baidu.com/album/w%3D2048/sign=bb86f9319213b07ebdbd570838ef9023/e61190ef76c6a7ef8e6fd636fcfaaf51f3de6650.jpg",
//						   @"http://c.hiphotos.baidu.com/album/w%3D2048/sign=f1d11d6214ce36d3a20484300ecb3b87/3801213fb80e7becfe83e2592e2eb9389b506b29.jpg",
//						   @"http://c.hiphotos.bdimg.com/album/s%3D1100%3Bq%3D90/sign=7b8d7dbfd2a20cf44290fade46397047/5bafa40f4bfbfbed896bcc477af0f736afc31fd3.jpg",
//						   @"http://f.hiphotos.baidu.com/album/w%3D2048/sign=df9a8c9ab17eca8012053ee7a51b96dd/91ef76c6a7efce1bf09de273ae51f3deb58f65d0.jpg",
//						   @"http://c.hiphotos.baidu.com/album/w%3D2048/sign=98a7c2751f178a82ce3c78a0c23b728d/63d9f2d3572c11dfb36d879a622762d0f603c2ce.jpg",
//						   @"http://e.hiphotos.bdimg.com/album/s%3D1100%3Bq%3D90/sign=61522ef69b25bc312f5d05996eefb6c0/29381f30e924b899e5a682006c061d950a7bf674.jpg",
//						   @"http://f.hiphotos.baidu.com/album/w%3D2048/sign=b7378e1d49fbfbeddc59317f4cc8f636/267f9e2f07082838f2a8c336ba99a9014c08f16f.jpg",
//						   @"http://h.hiphotos.bdimg.com/album/s%3D1200%3Bq%3D90/sign=fd3a3d17bc096b6385195a523c03bc35/cc11728b4710b9123f800cc6c1fdfc0392452241.jpg",
//						   @"http://a.hiphotos.baidu.com/album/w%3D2048/sign=e34d45eff636afc30e0c38658721ebc4/e824b899a9014c088e04208a0b7b02087bf4f4e6.jpg",
//						   @"http://c.hiphotos.baidu.com/album/w%3D2048/sign=a143821e9113b07ebdbd570838ef9023/e61190ef76c6a7ef94aaad19fffaaf51f3de6604.jpg"];
//		for (NSString * url in urls) {
//			CPhotoBrowserNetPhoto * photo = [[CPhotoBrowserNetPhoto alloc]init];
//			photo.photoURL = [NSURL URLWithString:url];
//			[photos addObject:photo];
//		}
	}
  
    return photos;
}

#pragma mark - CPhotoBrowserDelegate

- (void)photoBrowser:(CPhotoBrowserViewController *)photoBrowser didClickSaveButtonAtPageIndex:(NSUInteger)pageIndex
{
    
}
@end
