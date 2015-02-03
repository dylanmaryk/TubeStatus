//
//  AppDelegate.m
//  TubeStatus
//
//  Created by Dylan Maryk on 28/06/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import "AppDelegate.h"
#import "DataModel.h"
#import "AFHTTPRequestOperationManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeSound categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    [DataModel updateRemoteSettings];
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *deviceTokenString = [self deviceTokenStringFromData:deviceToken];
    
    if (![deviceTokenString isEqualToString:[[DataModel getUserDefaults] valueForKey:@"deviceToken"]]) {
        [DataModel setUserDefaultsObject:deviceTokenString forKey:@"deviceToken" andSync:NO];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [DataModel updateRemoteSettings];
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [DataModel updateRemoteSettings];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [DataModel updateRemoteSettings];
}

- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [DataModel updateRemoteSettings];
    [DataModel getRefreshedData];
    
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
