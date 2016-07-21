
#import "CCAppManager.h"
#import <UIKit/UIKit.h>
@interface CCAppManager ()

@end

@implementation CCAppManager


+ (instancetype)sharedInstance {
	static CCAppManager *sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedInstance = [[self alloc] init];
    });
	return sharedInstance;
}
/**
 *  初始化信息配置
 */
- (void)configureApp{
    /**
     *  一大堆配置信息 初始化网络 设置基本颜色啥的
     */
    
    
    [self getWhiteVerdionList];

}

/**
 *  懒加载
 */
- (CCAppVersionModel *)versionInfo{
    if (!_versionInfo) {
        _versionInfo = [CCAppVersionModel new];
    }
    return _versionInfo;
}
/**
 *  向自己的后台请求白名单信息
 */
- (void)getWhiteVerdionList {
    /**
     *  此处需要调用自己的接口 格式可以自己定义 
        我就不再走网络请求了，json格式直接扔到本地了
     */
    NSString *jsonPath = [[NSBundle mainBundle]pathForResource:@"version" ofType:@"json"];
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:jsonPath];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jdata options:0 error:nil];
    
    /**
     *  建议建个模型  我一般使用JsonModel  此处为了方便直接取值
     */
    NSArray *dataArr = dic[@"data"];
    NSDictionary *iosDic = dataArr[0];
    NSArray *whiteList = iosDic[@"ios"];
    
    
    
    BOOL needUpdate = YES;
    for (NSString *version in whiteList) {
        NSString *verStr;
        if (version.length > 4) {
            verStr = [version substringToIndex:5];
        } else {
            verStr = version;
        }
        if ([verStr isEqualToString:VERSION]) {
            needUpdate = NO;
        }
    }
    if (needUpdate) {
        [CCAppManager sharedInstance].needsForceUpdate = YES;
    }
    
    [[CCAppManager sharedInstance]checkAppVersionIsInitiative:NO];
    
}

/**
 *  版本更新是否退出登录 或者清除数据库什么的 暂时用不到
 */
- (void)cheackAppVersion{
    
}

/**
 *  @param flag 当初是为了住的检测版本设计的 现在Apple不让显示出“版本检测”的按钮了 就没什么用了
 */
- (void)checkAppVersionIsInitiative:(BOOL)flag{
    /**
     *  APP_ID 请替换成自己的APPID
     */
    NSString *URLString = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@", APP_ID];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:URLString]];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:15.0f];
    __weak __typeof(&*self)weakSelf = self;
    __block NSHTTPURLResponse *urlResponse = nil;
    __block NSError *error = nil;
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSData *recervedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
        
        if (recervedData && recervedData.length > 0) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:recervedData options:NSJSONReadingMutableLeaves error:&error];
            NSArray *infoArray = [dict objectForKey:@"results"];
            if (infoArray && infoArray.count > 0) {
                NSDictionary *releaseInfo = [infoArray objectAtIndex:0];
                //描述
                weakSelf.versionInfo.releaseNote = releaseInfo[@"releaseNotes"];
                weakSelf.versionInfo.version = releaseInfo[@"version"];
                weakSelf.versionInfo.URI = releaseInfo[@"trackViewUrl"];
                
                if (weakSelf.needsForceUpdate) {
                    //强制更新 发送通知   通知接受对象可以更加自己项目情况来定
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationAppShouldUpdate object:@{@"URI":weakSelf.versionInfo.URI}];
                    return;
                }
                //是否忽略这个版本
                weakSelf.versionIgnored = ([weakSelf.versionInfo.version isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:UDkUpdateIgnoredVersion]]);
                //要判断这里忽略过的版本是不是更新了 和本地版本号已经一样了
                if ([VERSION isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:UDkUpdateIgnoredVersion]]) {
                    weakSelf.versionIgnored = NO;
                    [[NSUserDefaults standardUserDefaults]removeObjectForKey:UDkUpdateIgnoredVersion];
                }
                weakSelf.hasNewVersion = ([VERSION compare:weakSelf.versionInfo.version options:NSNumericSearch] == NSOrderedAscending);
                
                if (weakSelf.versionIgnored&&!flag) {
                    NSLog(@"忽略的版本");
                    return;
                }
                if (weakSelf.hasNewVersion) {
                    if (!flag) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"新版本%@",weakSelf.versionInfo.version] message:[NSString stringWithFormat:@"%@",weakSelf.versionInfo.releaseNote] delegate:self cancelButtonTitle:@"关闭" otherButtonTitles:@"立即更新",@"忽略此版本", nil];
                        alert.tag = 10000;
                        [alert show];
                        
                    }else{
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"新版本%@",weakSelf.versionInfo.version] message:[NSString stringWithFormat:@"%@",weakSelf.versionInfo.releaseNote] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"立即更新", nil];
                        alert.tag = 10000;
                        [alert show];
                    }
                    
                } else {
                    if (flag) {
                        
                        //[HTUIHelper alertMessage:@"已经是最新版本"];
                        
                    }
                }
            } else {
                if (flag) {
                    
                    //[HTUIHelper alertMessage:@"检测失败,请稍后再试"];
                    
                }
            }
        }
        else {
            //[HTUIHelper alertMessage:@"检测失败,请稍后再试"];
        }
        
    }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10000) {
        if (buttonIndex == 1) {
            //            NSString *iTunesLink = [NSString stringWithFormat:@"itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=%@&mt=8", APP_ID];
            NSURL *url = [NSURL URLWithString:self.versionInfo.URI];
            if ([[UIApplication sharedApplication]canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }else if(buttonIndex ==2){
            //忽略此版本
            [self ignoreCurrentVersion];
        }
    }
}

- (void)ignoreCurrentVersion {
    
    [[NSUserDefaults standardUserDefaults] setObject:self.versionInfo.version forKey:UDkUpdateIgnoredVersion];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end



@implementation CCAppVersionModel

@end
