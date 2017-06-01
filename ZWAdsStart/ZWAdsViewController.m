//
//  ZWAdsViewController.m
//  ZWAdsStart
//
//  Created by ziwen on 2017/5/31.
//  Copyright © 2017年 ABC.com. All rights reserved.
//

#import "ZWAdsViewController.h"

@interface ZWAdsViewController ()

@property (nonatomic, strong) UIWebView *webView;
@end

@implementation ZWAdsViewController
- (void)loadView
{
    [super loadView];
    [self.view addSubview:self.webView];
    self.navigationItem.leftBarButtonItem = [self leftNavBackButtonTitle:@"返回" target:self action:@selector(popBack:)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSString *path = @"https://github.com/ziwen/ZWAdsStart";
    NSURL *url = [NSURL URLWithString:path];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIBarButtonItem *)leftNavBackButtonTitle:(NSString *)title target:(id)target action:(SEL)action {
    UIButton *bGoBack = [UIButton buttonWithType:UIButtonTypeCustom];
    bGoBack.frame = CGRectMake(0, 0, 46, 24);
    
    bGoBack.titleLabel.font = [UIFont systemFontOfSize:17];
    [bGoBack setTitle:title forState:UIControlStateNormal];
    [bGoBack setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //    [bGoBack setImage:[UIImage imageNamed:@"nav_back_normal"] forState:UIControlStateNormal];
    //    [bGoBack setImage:[UIImage imageNamed:@"nav_back_highlighted"] forState:UIControlStateHighlighted];
    [bGoBack setImageEdgeInsets:UIEdgeInsetsMake(0, -9, 0, 0)];
    [bGoBack addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:bGoBack];
}

-(UIWebView *)webView
{
    if (!_webView)
    {
        _webView = [[UIWebView alloc] init];
        _webView.frame = self.view.bounds;
//        _webView.delegate = self;
        _webView.scrollView.bounces = NO;
        _webView.scrollView.scrollEnabled = YES;
        _webView.scrollView.showsHorizontalScrollIndicator = YES;
    }
    return _webView;
}


- (void)popBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
