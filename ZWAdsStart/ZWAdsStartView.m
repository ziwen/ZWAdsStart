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



#define kZWDEFAULTTIME 3

#define BLOCK_ONE(block,result) if(block) block(result);
#define BLOCK(block) if(block) block();


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

@property (nonatomic, strong) UIImageView *bgImageViewDefault;//默认的背景视图
@property (nonatomic, strong) ZWClickAdsImageView *bgImageView;
@property (nonatomic, strong) UIButton *timeButton;

@property (nonatomic, assign) BOOL isImageDownloaded;

@property (nonatomic) NSUInteger timeNum; //显示的数值
@property (nonatomic, strong) NSTimer *timer;//计时器

@end


@implementation ZWAdsStartView
#pragma mark - private method


- (instancetype)init
{
    self = [super init];
    if (self) {

        [self setFrame:[UIScreen mainScreen].bounds];
        _isImageDownloaded = NO;
        self.time = kZWDEFAULTTIME;
        
    }
    return self;
}

-(void)setTime:(NSUInteger)time
{
    _time = time;
    _timeNum = time;
}

- (BOOL)loadImage
{
    SDWebImageManager *imageMngr = [SDWebImageManager sharedManager];
    
    NSURL *imageURL = [NSURL URLWithString:self.imageUrl];
    // 将需要缓存的图片加载进来
    BOOL cachedBool = [imageMngr cachedImageExistsForURL:imageURL];
    
    
    BOOL diskBool = [imageMngr diskImageExistsForURL:imageURL];
    if (cachedBool || diskBool)
    {
        _timeButton.hidden = NO;
        [self.bgImageView sd_setImageWithURL:imageURL placeholderImage:[[self class] getTheLaunchImage]];
        _isImageDownloaded = YES;
    }
    else
    {
        _timeButton.hidden = YES;
        self.bgImageView.image = [[self class] getTheLaunchImage];;
        _isImageDownloaded = NO;
    }

    return !_timeButton.hidden;
}

- (UIImageView *)bgImageViewDefault
{
    if (!_bgImageViewDefault)
    {
        _bgImageViewDefault = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _bgImageViewDefault.contentMode = UIViewContentModeScaleToFill;
        _bgImageViewDefault.image = [[self class] getTheLaunchImage];
    }
    return _bgImageViewDefault;
}

- (UIButton *)timeButton
{
    if (!_timeButton) {
        _timeButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 13 - 52, 20, 52, 25)];
        _timeButton.layer.cornerRadius = 25/2.0f;
        [_timeButton setClipsToBounds:YES];
        _timeButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        _timeButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_timeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_timeButton addTarget:self action:@selector(jumpClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _timeButton;
}

-(ZWClickAdsImageView *)bgImageView
{
    if (!_bgImageView) {
        _bgImageView = [[ZWClickAdsImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _bgImageView.alpha = 0.0;
        _bgImageView.contentMode = UIViewContentModeScaleToFill;
        [_bgImageView addTarget:self action:@selector(imageClicked:)];
    }
    return _bgImageView;
}


- (void)imageClicked:(id)sender
{
    if (self.isImageDownloaded)
    {
        BLOCK(_imageClickAction);
    }

    //删除广告
    [self removeAdsView];
}

- (void)jumpClicked:(UIButton *)sender
{
    NSInteger timeInterval = _time - _timeNum > 0 ? _time - _timeNum : _time;
    BLOCK_ONE(_adsJumpClickAction, timeInterval);
    [self removeAdsView];
}

- (void)timerAction:(id)sender
{
    if (_timeNum <= 0)
    {
        [self removeAdsView];
        BLOCK(_adsCompletion);
        return;
    }

    _timeNum--;
    if (_isImageDownloaded)
    {
        [self setTimeButtonNumber];
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

    }];
}

- (void)buildView
{
    //默认的应用启动图
    [self addSubview:self.bgImageViewDefault];
    
    //图片源视图
    [self addSubview:self.bgImageView];
    
    //时间按钮
    [self.bgImageView addSubview:self.timeButton];
    
}

- (BOOL)startShowAds
{
    if (NO == [self isViewContainSelf])
    {
        BOOL loadSuccess = [self loadImage];
        [self buildView];

        if (loadSuccess)
        {
            [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
            [[[[UIApplication sharedApplication] delegate] window] bringSubviewToFront:self];
            [[UIApplication sharedApplication].keyWindow addSubview:self];
            [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];

            [UIView animateWithDuration:0.5f animations:^{
                _bgImageView.alpha = 1.0f;
            }];


            [self setTimeButtonNumber];

            //开始计时
            [_timer invalidate];
            _timer = nil;
            _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
            return YES;
        }
        else
        {
            BLOCK(_adsCompletion);
            return NO;
        }
    }
    return NO;
}

- (BOOL)isViewContainSelf
{
    NSArray *views = [[[UIApplication sharedApplication] delegate] window].subviews;
    BOOL isContionSelf = NO;
    for (UIView *view in views) {
        if ([view isEqual:self]) {
            isContionSelf = YES;
        }
    }
    return isContionSelf;
}

- (void)setTimeButtonNumber
{
    NSString *title = [NSString stringWithFormat:@"跳过%zd",_timeNum];
    [_timeButton setTitle:title forState:UIControlStateNormal];
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


