//
//  CCAppManager.h
//  CCAppVersionManager
//
//  Created by CC on 16/7/21.
//  Copyright © 2016年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>
static NSString * const kStatusBarTappedNotification = @"statusBarTappedNotification";
static NSString * const kNotificationAppShouldUpdate = @"appShouldUpdate";
static NSString *const UDkUpdateIgnoredVersion = @"UpdateIgnoredVersion";

#define VERSION (NSString *)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define APP_ID @"1035505672"

@class CCAppVersionModel;
@interface CCAppManager : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic) CCAppVersionModel *versionInfo;


/// 新版本是否已忽略
@property (readwrite, nonatomic) BOOL versionIgnored;
/// 是否强制用户升级
@property (readwrite, nonatomic) BOOL needsForceUpdate;
/**
 *  是否有新版本
 */
@property (readwrite, nonatomic) BOOL hasNewVersion;

- (void)configureApp;
- (void)cheackAppVersion;

// 检查应用版本
- (void)checkAppVersionIsInitiative:(BOOL)flag;

@end






@interface CCAppVersionModel : NSObject
/// 版本号
@property (strong, nonatomic) NSString *version;

/// 标识
@property (strong, nonatomic) NSString *URI;

/// 描述
@property (strong, nonatomic) NSString *releaseNote;

/// 最低版本
@property (strong, nonatomic) NSString *minimalRequiredVersion;
@end
