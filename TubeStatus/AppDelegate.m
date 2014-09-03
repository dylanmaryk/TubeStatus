//
//  AppDelegate.m
//  TubeStatus
//
//  Created by Dylan Maryk on 28/06/2014.
//  Copyright (c) 2014 Dylan Maryk. All rights reserved.
//

#import "AppDelegate.h"
#import "DataModel.h"
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
    
    if (![deviceTokenString isEqualToString:[[DataModel getUserDefaults] valueForKey:@"deviceToken"]]) {
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        [manager POST:@"http://api.tubestatus.dylanmaryk.com/tokens" parameters:@{ @"devicetoken": deviceTokenString } success:^(AFHTTPRequestOperation *operation, id responseObject) {
            [DataModel setUserDefaultsObject:deviceTokenString forKey:@"deviceToken"];
        } failure:nil];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    NSString *lineDescription = [userInfo valueForKey:@"description"];
//    NSString *lineStatusDetails = [userInfo valueForKey:@"statusDetails"];
//    NSString *lineStatus;
//    
//    if (lineStatusDetails) {
//        lineStatus = [NSString stringWithFormat:@"%@: %@", lineDescription, lineStatusDetails];
//    } else {
//        lineStatus = [NSString stringWithFormat:@"%@", lineDescription];
//    }
//    
//    UILocalNotification *statusUpdateNotification = [[UILocalNotification alloc] init];
//    statusUpdateNotification.alertBody = [NSString stringWithFormat:@"%@ - %@", [userInfo valueForKey:@"line"], lineStatus];
//    statusUpdateNotification.soundName = UILocalNotificationDefaultSoundName;
//    
//    [[UIApplication sharedApplication] presentLocalNotificationNow:statusUpdateNotification];
//    
//    completionHandler(UIBackgroundFetchResultNoData);
    
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
