//
//  ZWAdsStartView.h
//  ZWAdsStart
//
//  Created by ziwen on 26/10/2016.
//  Copyright © 2016 ABC. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef  void(^ImageClickAction)();;
typedef void(^AdsCompletion)();
typedef void(^AdsJumpClickAction)(NSInteger timeInterval);//time 用户第几s点击了跳转，用于统计用户看广告的时间

@interface ZWAdsStartView : UIView

/**
 * 启动广告图的url，,必须设置，不然不启动
 */
@property (nonatomic, copy) NSString *imageUrl;

/**
 * 启动广告显示的时间，,可以不设置，默认3s
 */
@property (nonatomic, assign) NSUInteger time;

/**
 * 启动广告图的点击回调，跳转到广告页，
 */
@property (nonatomic, copy) ImageClickAction imageClickAction;//带参数
/**
 * 启动广告图的跳过回调，可以做一些额外的数据处理
 */
@property (nonatomic, copy) AdsJumpClickAction adsJumpClickAction;
/**
 * 启动广告图的正常进行，可以做一些额外的数据处理
 */
@property (nonatomic, copy) AdsCompletion adsCompletion;


- (BOOL)startShowAds;

///**
// *  广告的图层显示
// */
//+ (instancetype)startAdsViewWithBgImageUrl:(NSString *)imageUrl withClickImageAction:(void(^)())action;
//
///**
// *  开启动画
// */
//- (void)startAnimationTime:(NSUInteger)time WithCompletionBlock:(void(^)(ZWAdsStartView* imStartView))completionHandler;

@end
