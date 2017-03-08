//
//  AppDelegate.m
//  HIPTestApp
//
//  Created by 李腾飞 on 2017/3/8.
//  Copyright © 2017年 李腾飞. All rights reserved.
//

#import "AppDelegate.h"
#import "HIPMainViewController.h"
#import "HIPUtility.h"
#import "HIPWebViewController.h"
#import "HIPStringUtility.h"

@interface AppDelegate ()

@property (retain, nonatomic) HIPMainViewController *mainViewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [HIPUtility initNavigationBarStyle];
    
    [self.window makeKeyAndVisible];
    [self.window setRootViewController:self.mainViewController];
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

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[url scheme] isEqualToString:@"hippo"]) {
        NSString *alertStr = [HIPStringUtility getValueFromUrl:url forParam:@"alert"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"URL打开APP" message:alertStr delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return YES;
    }
    return NO;
}

#pragma mark private

- (HIPMainViewController *)mainViewController {
    if (!_mainViewController) {
        _mainViewController = [[HIPMainViewController alloc] init];
    }
    return _mainViewController;
}

@end
