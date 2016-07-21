//
//  AppDelegate.m
//  CCAppVersionManager
//
//  Created by CC on 16/7/21.
//  Copyright © 2016年 cc. All rights reserved.
//

#import "AppDelegate.h"
#import "CCAppManager.h"

#import "CCGotoUpDateViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [[CCAppManager sharedInstance]configureApp];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(shouldUpdateApp:) name:kNotificationAppShouldUpdate object:nil];

    return YES;
}

- (void)shouldUpdateApp:(NSNotification *)notification {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        id userInfo = notification.object;
        CCGotoUpDateViewController *updateVC = [[CCGotoUpDateViewController alloc] init];
        updateVC.urlStr = [userInfo objectForKey:@"URI"];
        
        [self.window setRootViewController:updateVC];
//        [self presentViewController:updateVC animated:NO completion:^{
//            
//        }];
    });
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
