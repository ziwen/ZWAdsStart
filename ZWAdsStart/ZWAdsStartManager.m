//
//  ZWAdsStartManager.m
//  ZWAdsStart
//
//  Created by ziwen on 2017/6/1.
//  Copyright © 2017年 ABC.com. All rights reserved.
//

#import "ZWAdsStartManager.h"

#import "ZWAdsStartView.h"
#import "ZWAdsViewController.h"

#import "UIImageView+WebCache.h"

#import "SDWebImageDownloader.h"

#define ADVIERTISEMENT_DOWNLOAD_KEY @"zwadvisement_download_key"

NSString * const kZWDSSTARTIMAGE = @"zw_ads_start_image";


@interface ZWAdsModel : NSObject

@property (nonatomic, strong) NSString *imageUrl;
@property (nonatomic, strong) NSString *pageUrl;

+ (instancetype)modelWithDic:(NSDictionary *)dic;
@end

@implementation ZWAdsModel

+ (instancetype)modelWithDic:(NSDictionary *)dic
{
   return  [[ZWAdsModel alloc] initWithDic:dic];
}

- (instancetype)initWithDic:(NSDictionary *)dic
{
    if (self = [super init]) {
        _imageUrl = dic[@"image"];
        _pageUrl = dic[@"url"];

    }
    return self;
}

@end


//////////////////////////////////////////////////////////////
//                      广告管理器
//////////////////////////////////////////////////////////////


@implementation ZWAdsStartManager

+ (void)shouldLoadAds
{
    //加载广告逻辑,
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:ADVIERTISEMENT_DOWNLOAD_KEY] isEqualToString:@"1"])
    {
        ZWAdsModel *adsModel = [self adsStartImageUrl];

        NSString *imageUrl = adsModel.imageUrl;
        if (imageUrl)
        {
            ZWAdsStartView *adsStartView = [[ZWAdsStartView alloc] init];

            adsStartView.imageUrl = imageUrl;
            adsStartView.time = 5;
            adsStartView.adsCompletion = ^(){
                NSLog(@"adsCompletion");
            };

            adsStartView.imageClickAction = ^{
                ZWAdsViewController *VC = [[ZWAdsViewController alloc] init];
                VC.title = @"Ads Page";
                VC.pageUrl = adsModel.pageUrl;
                UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:VC];
                //    [navCtrl pushViewController:VC animated:YES];

                UIWindow *window = [UIApplication sharedApplication].keyWindow;
                [(UINavigationController *)window.rootViewController presentViewController:navCtrl animated:YES completion:nil];
            };
            adsStartView.adsJumpClickAction = ^(NSInteger timeInterval) {
                NSLog(@"adsJumpClickAction use time:%ld",timeInterval);
            };


            [adsStartView startShowAds];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //下载图片，可以单独写，与view分开
            [self downloadStartImage];
        });
    }
    else // 第一次先下载广告
    {
        //下载图片
        [self downloadStartImage];
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:ADVIERTISEMENT_DOWNLOAD_KEY];
    }
}


+ (ZWAdsModel *)adsStartImageUrl
{
  return [ZWAdsModel modelWithDic:[[NSUserDefaults standardUserDefaults] objectForKey:kZWDSSTARTIMAGE]];
}

+ (void)downloadStartImage
{

    NSString *image1 = @"http://img5.duitang.com/uploads/item/201407/27/20140727015257_niMk8.jpeg"; //鹅卵石
    NSString *image2 = @"https://785j3g.com1.z0.glb.clouddn.com/d659db60-f.jpg";//小孩
    NSString *image3 = @"https://imgsrc.baidu.com/forum/w%3D580/sign=ed8c959c57fbb2fb342b581a7f4b2043/6a444c086e061d95be19aaf979f40ad163d9ca5e.jpg";//科比
    NSString *image4 =@"http://g.hiphotos.baidu.com/zhidao/pic/item/d52a2834349b033b550089fd12ce36d3d539bd08.jpg";//苹果手机壁纸

    NSString *url = @"https://github.com/ziwen/ZWAdsStart";
    NSArray *imageArray = @[
                            @{
                                @"image":image1,
                                @"url":url
                                },
                            @{
                                @"image":image2,
                                @"url":url
                                },
                            @{
                                @"image":image3,
                                @"url":url
                                },
                            @{
                                @"image":image4,
                                @"url":url
                                },
                            ];
    //模拟从服务器下载广告图片url
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        srand((unsigned)time(0));
        int value = arc4random() % 4;


        NSDictionary *imgDic = [imageArray objectAtIndex:value];
        ZWAdsModel *adsModel = [ZWAdsModel modelWithDic:imgDic];
        NSString *imageUrl = adsModel.imageUrl;

        NSURL *imageURL = [NSURL URLWithString:imageUrl];
        SDWebImageManager *imageMngr = [SDWebImageManager sharedManager];
        
        BOOL cachedBool =  [imageMngr cachedImageExistsForURL:imageURL];
        BOOL diskBool = [imageMngr diskImageExistsForURL:imageURL];
        
        if (cachedBool || diskBool)
        {
            //已经缓存过了，暂不缓存
            [[NSUserDefaults standardUserDefaults] setObject:imgDic forKey:kZWDSSTARTIMAGE];
        }
        else //没有缓存，缓存图片
        {
            [imageMngr downloadImageWithURL:imageURL options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                if (image && finished) {
                    [[NSUserDefaults standardUserDefaults] setObject:imgDic forKey:kZWDSSTARTIMAGE];
                }
            }];
        }
    });
}

@end



