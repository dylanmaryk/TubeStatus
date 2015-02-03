//
//  AppDelegate.m
//  TubeStatus
//
//  Created by Dylan Maryk on 28/06/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import "AppDelegate.h"
#import "DataModelAppOnly.h"
#import "AFHTTPRequestOperationManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [DataModelAppOnly updateRemoteSettings];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenString = [self deviceTokenStringFromData:deviceToken];
    
    if (![deviceTokenString isEqualToString:[[DataModelAppOnly getUserDefaults] valueForKey:@"deviceToken"]]) {
        [DataModelAppOnly setUserDefaultsObject:deviceTokenString forKey:@"deviceToken" andSync:NO];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [DataModelAppOnly updateRemoteSettings];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [DataModelAppOnly updateRemoteSettings];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [DataModelAppOnly updateRemoteSettings];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [DataModelAppOnly updateRemoteSettings];
    [DataModelAppOnly getRefreshedData];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (NSString *)deviceTokenStringFromData:(NSData *)deviceToken {
    const char *deviceTokenData = deviceToken.bytes;
    
    NSMutableString *deviceTokenString = [NSMutableString string];
    
    for (int i = 0; i < deviceToken.length; i++) {
        [deviceTokenString appendFormat:@"%02.2hhX", deviceTokenData[i]];
    }
    
    return deviceTokenString.copy;
}

@end
