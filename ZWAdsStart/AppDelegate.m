//
//  AppDelegate.m
//  ZWAdsStart
//
//  Created by ziwen on 2017/5/31.
//  Copyright © 2017年 ABC.com. All rights reserved.
//

#import "AppDelegate.h"

#import "ViewController.h"
#import "ZWAdsStartManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  
    ViewController *viewCtrl = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:viewCtrl];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    
    //用户自己点击启动
    if(!launchOptions)
    {
        NSLog(@"用户点击app启动");
        //检测是否需要加载广告页，必须放在makeKeyAndVisiblev后面，否则不起作用
        [ZWAdsStartManager shouldLoadAds];
    }
    else
    {
        NSURL *url = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
        //app 通过urlscheme启动
        if (url) {
            NSLog(@"app 通过urlscheme启动 url = %@",url);
        }
        UILocalNotification *localNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        //通过本地通知启动
        if(localNotification)
        {
            NSLog(@"app 通过本地通知启动 localNotification = %@",localNotification);
        }
        NSDictionary *remoteCotificationDic = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        //远程通知启动
        if(remoteCotificationDic)
        {
            NSLog(@"app 通过远程推送通知启动 remoteCotificationDic = %@",remoteCotificationDic);
        }
    }
  
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
