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
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
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
    completionHandler(UIBackgroundFetchResultNoData);
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
