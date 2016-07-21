
#import "CCGotoUpDateViewController.h"

@interface CCGotoUpDateViewController ()
@end

@implementation CCGotoUpDateViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    
    UIImageView *imageV = [[UIImageView alloc] initWithFrame:self.view.bounds];
    imageV.image = [UIImage imageNamed:@"Launch"];
    [self.view addSubview:imageV];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popUpAlert)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    [self popUpAlert];
}

- (void)popUpAlert {
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发现需要升级的版本，现在去更新?" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    [self gotoUpdate:nil];
}

- (void)gotoUpdate:(id)sender {
    //https://itunes.apple.com/us/app/5tv-shou-ji-ju/id940044276?l=zh&ls=1&mt=8
    //    NSString *iTunesLink = [NSString stringWithFormat:@"itms-apps://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftwareUpdate?id=%@&mt=8", APP_ID];
    //    NSString *iTunesLink = [NSString stringWithFormat:@"https://itunes.apple.com/us/app/5tv-shou-ji-ju/id%@?l=zh&ls=1&mt=8", APP_ID];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlStr]];
}
@end

