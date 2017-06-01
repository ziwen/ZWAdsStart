//
//  ZWAdsStartView.h
//  ZWAdsStart
//
//  Created by ziwen on 26/10/2016.
//  Copyright © 2016 ABC. All rights reserved.
//

#import <UIKit/UIKit.h>


#define ADVIERTISEMENT_DOWNLOAD_KEY @"zwadvisement_download_key"

/**
 *  存储广告图片url的key
 */
extern NSString *const kZWDSSTARTIMAGE;



@interface ZWAdsStartView : UIView

/**
 *  存储广告图片url
 */
+ (NSString *)adsStartImageUrl;
//+ (void)downloadStartImage;

/**
 *  广告的图层显示
 */
+ (instancetype)startAdsViewWithBgImageUrl:(NSString *)imageUrl withClickImageAction:(void(^)())action;

/**
 *  开启动画
 */
- (void)startAnimationTime:(NSUInteger)time WithCompletionBlock:(void(^)(ZWAdsStartView* imStartView))completionHandler;

@end
