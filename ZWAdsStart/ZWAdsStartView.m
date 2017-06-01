//
//  ZWAdsStartView.m
//  ZWAdsStart
//
//  Created by ziwen on 2017/5/31.
//  Copyright © 2017年 ABC.com. All rights reserved.
//

#import "ZWAdsStartView.h"
#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"

NSString * const kZWDSSTARTIMAGE = @"zw_ads_start_image1";

//////////////////////////////////////////////////////////////
//                      可点击的image视图
//////////////////////////////////////////////////////////////

@interface ZWClickAdsImageView : UIImageView

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;
-(void)addTarget:(id)target action:(SEL)action;

@end

@implementation ZWClickAdsImageView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = YES;
    }
    return self;
}

-(void)addTarget:(id)target action:(SEL)action
{
    self.target = target;
    self.action = action;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.target respondsToSelector:self.action])
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.action withObject:self];
#pragma clang diagnostic pop
    }
}

@end


//////////////////////////////////////////////////////////////
//                      广告页
//////////////////////////////////////////////////////////////


@interface ZWAdsStartView ()

@property (nonatomic, strong) UIImageView *bgImageViewDefault;
@property (nonatomic, strong) ZWClickAdsImageView *bgImageView;
@property (nonatomic, strong) UIButton *timeButton;

@property (nonatomic, copy) void(^imageClickAction)();
@property (nonatomic, copy) void(^adsViewCompletion)(ZWAdsStartView *imStartView);

@property (nonatomic, assign) BOOL isImageDownloaded;

@property (nonatomic) NSUInteger timeNum;
@property (nonatomic, strong) NSTimer *timer;//计时器

@end


@implementation ZWAdsStartView
#pragma mark - private method

- (instancetype)initWithBgImageUrl:(NSString *)imageUrl withClickImageAction:(void(^)())action
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self)
    {
        _isImageDownloaded = NO;
        _imageClickAction = action;
        
        _bgImageViewDefault = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _bgImageViewDefault.contentMode = UIViewContentModeScaleToFill;
        _bgImageViewDefault.image = [[self class] getTheLaunchImage];

        [self addSubview:_bgImageViewDefault];
        
        _bgImageView = [[ZWClickAdsImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _bgImageView.alpha = 0.0;
        _bgImageView.contentMode = UIViewContentModeScaleToFill;
        [_bgImageView addTarget:self action:@selector(imageClicked:)];
        [self addSubview:_bgImageView];

        //时间按钮
        _timeButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 13 - 52, 20, 52, 25)];
        _timeButton.layer.cornerRadius = 25/2.0f;
        [_timeButton setClipsToBounds:YES];
        _timeButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _timeButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_timeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_timeButton addTarget:self action:@selector(jumpClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_bgImageView addSubview:_timeButton];


        //加载图片
        SDWebImageManager *imageMngr = [SDWebImageManager sharedManager];
     
        // 将需要缓存的图片加载进来
        BOOL cachedBool = [imageMngr cachedImageExistsForURL:[NSURL URLWithString:imageUrl]];
       
    
        BOOL diskBool = [imageMngr diskImageExistsForURL:[NSURL URLWithString:imageUrl]];
        if (cachedBool || diskBool)
        {
            _timeButton.hidden = NO;
            [self.bgImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[[self class] getTheLaunchImage]];
            _isImageDownloaded = YES;
        }
        else
        {
            _timeButton.hidden = YES;
            self.bgImageView.image = [[self class] getTheLaunchImage];;
            [imageMngr downloadImageWithURL:[NSURL URLWithString:imageUrl] options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize) {

            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
               [[NSUserDefaults standardUserDefaults] setObject:imageUrl forKey:kZWDSSTARTIMAGE];
            }];
            _isImageDownloaded = NO;
        }
    }
    return self;
}


- (void)imageClicked:(id)sender
{
    if (self.imageClickAction && self.isImageDownloaded)
    {
        self.imageClickAction();
        //删除广告
        [self removeAdsView];
    }
}

- (void)jumpClicked:(UIButton *)sender
{
    [self removeAdsView];
}

- (void)timerAction:(id)sender
{
    if (_timeNum == 0)
    {
        [self removeAdsView];
        return;
    }

    _timeNum--;
    if (_isImageDownloaded)
    {
        NSString *title = [NSString stringWithFormat:@"跳过%zd",_timeNum];
        [_timeButton setTitle:title forState:UIControlStateNormal];
    }
}

- (void)removeAdsView
{
    if (_timer.isValid)
    {
        [_timer invalidate];
    }
    _timer = nil;

    __weak typeof(self)  weakSelf = self;

    [UIView animateWithDuration:0.7 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.bgImageView.alpha = 0.0;
        weakSelf.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
        if (_adsViewCompletion)
        {
            _adsViewCompletion(weakSelf);
        }
    }];
}

- (void)startAnimationTime:(NSUInteger)time WithCompletionBlock:(void(^)(ZWAdsStartView *imStartView))completionHandler
{
    _timeNum = time;
    _adsViewCompletion = completionHandler;
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
    [[[[UIApplication sharedApplication] delegate] window] bringSubviewToFront:self];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
    [UIView animateWithDuration:0.5f animations:^{
        _bgImageView.alpha = 1.0f;
    }];
    
    NSString *title = [NSString stringWithFormat:@"跳过%zd",_timeNum];
    [_timeButton setTitle:title forState:UIControlStateNormal];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
}


+ (instancetype)startAdsViewWithBgImageUrl:(NSString *)imageUrl withClickImageAction:(void(^)())action
{
    return [[[self class] alloc] initWithBgImageUrl:imageUrl withClickImageAction:action];
}


+ (NSString *)adsStartImageUrl
{
   return [[NSUserDefaults standardUserDefaults] objectForKey:kZWDSSTARTIMAGE];
}

+ (UIImage *)getTheLaunchImage
{
    CGSize viewSize = [UIScreen mainScreen].bounds.size;

    NSString *viewOrientation = nil;
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait)) {
        viewOrientation = @"Portrait";
    }
    else
    {
        viewOrientation = @"Landscape";
    }

    NSString *launchImage = nil;

    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];

    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);

        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImage = dict[@"UILaunchImageName"];
        }
    }

    return [UIImage imageNamed:launchImage];
}

@end


