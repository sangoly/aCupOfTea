//
//  LXSchoolNetManager.m
//  aCupOfTea
//
//  Created by mwsn on 14-12-22.
//  Copyright (c) 2014年 Sangoly. All rights reserved.
//

#import "LXSchoolNetManager.h"
#import "LXUtil.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

#define BASE_URL @"http://10.3.8.211" //base and login url
#define RELOGIN_URL @"a11.htm" // relogin method
#define LOGOUT_URL @"F.htm" // Get method

#define WIFI_BASE_URL @"http://10.4.1.2"

#define MANAGE_BASE_URL @"http://gwself.bupt.edu.cn"
#define MANAGE_NAV_LOGIN @"nav_login" // GET method
#define MANAGE_LOGIN_URL @"LoginAction.action"
#define MANAGE_LOGOUT_URL @"LogoutAction.action"
#define MANAGE_ONLINE_DEVICE_URL @"nav_onffLine"
#define MANAGE_RANDOMCODE_URL @"RandomCodeAction.action?randomNum="

#define LOGIN YES
#define LOGOUT NO

@interface LXSchoolNetManager() {
    AFHTTPClient *schoolNetClient;
    AFHTTPClient *schoolWiFiNetClient;
    AFHTTPClient *deviceManageClient;
}

@end

@implementation LXSchoolNetManager

static NSMutableDictionary *ipToAddressMap;

- (id)init {
    self = [super init];
    if (self) {
        schoolNetClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:BASE_URL]];
        schoolWiFiNetClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:WIFI_BASE_URL]];
        deviceManageClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:MANAGE_BASE_URL]];
        [LXSchoolNetManager initIpToAddressMap];
        [self isWiFi];
    }
    return self;
}

#pragma mark - school net work opeartor

- (void)doSchoolNetWorkOperator:(NSInteger) row {
    // Pop up alert view
    UIAlertView *alertView;
    NSString *alertMessage;
    if (row == 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *username = [defaults stringForKey:@"username"];
        NSString *passwd = [defaults stringForKey:@"passwd"];
        BOOL forceLogin = [defaults boolForKey:@"force_login"];
        
        if (!username || !passwd) {
            alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"登录所用信息填写不全，请长按条目进入设置页面" delegate:Nil cancelButtonTitle:@"确定" otherButtonTitles:Nil, nil];
            [alertView show];
            return;
        }
        if (forceLogin == YES) {
            alertMessage = @"您确定要登录吗？当前选择模式为强制模式，这将会迫使您正在使用的账号下线。";
        } else {
            alertMessage = @"确定要登录吗？";
        }
        alertView = [[UIAlertView alloc] initWithTitle:@"校园网登录" message:alertMessage delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 1; // 1 refers login ensure dialog
        [alertView show];
    } else if (row == 1) {
        alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:@"确定注销校园网吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alertView.tag = 2; // 2 refers to logout ensure
        [alertView show];
    } else if (row == 2) {
        [self doOnlineDeviceManage];
    } else if (row == 3) {
        [self doBlanceSearch];
    }
}

- (void)doSchoolNetLogout {
    [schoolNetClient getPath:LOGOUT_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:[LXUtil getGB2312Code]];
        [self judgeLoginErrorType:result];
        NSLog(@"注销成功");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"注销失败%@", error);
        [self showNetWorkErrorAlert:nil];
    }];
}

- (void)doSchoolNetLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username"];
    NSString *passwd = [defaults stringForKey:@"passwd"];
    BOOL forceLogin = [defaults boolForKey:@"force_login"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:username forKey:@"DDDDD"];
    [params setObject:passwd forKey:@"upass"];
    if (forceLogin) {
        [params setObject:@"" forKey:@"AMKKey"];
    } else {
        [params setObject:@"" forKey:@"0MKKey"];
    }
    [schoolNetClient postPath:BASE_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:[LXUtil getGB2312Code]];
        //        NSLog(@"%@", result);
        
        NSString *testRegex = @"<title>登录成功窗</title>";
        NSRange range = [result rangeOfString:testRegex options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"通知" message:@"登录成功，不使用时记得断开连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            [self judgeLoginErrorType:result];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showNetWorkErrorAlert:nil];
    }];
}

// Wifi logout and login
- (void)doSchoolWiFiNetLogout {
    [schoolWiFiNetClient getPath:LOGOUT_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:[LXUtil getGB2312Code]];
        [self judgeLoginErrorType:result];
        NSLog(@"注销成功");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"注销失败%@", error);
        [self showNetWorkErrorAlert:nil];
    }];
}

- (void)doSchoolWiFiNetLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username"];
    NSString *passwd = [defaults stringForKey:@"passwd"];
    BOOL forceLogin = [defaults boolForKey:@"force_login"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:username forKey:@"DDDDD"];
    [params setObject:passwd forKey:@"upass"];
    if (forceLogin) {
        [params setObject:@"" forKey:@"AMKKey"];
    } else {
        [params setObject:@"" forKey:@"0MKKey"];
    }
    [schoolWiFiNetClient postPath:WIFI_BASE_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:[LXUtil getGB2312Code]];
        //        NSLog(@"%@", result);
        
        NSString *testRegex = @"<title>登录成功窗</title>";
        NSRange range = [result rangeOfString:testRegex options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"通知" message:@"登录成功，不使用时记得断开连接" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            [self judgeLoginErrorType:result];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showNetWorkErrorAlert:nil];
    }];
}

- (void)judgeLoginErrorType:(NSString *) resultString {
    NSString *regex;
    NSRange range;
    NSInteger msgFlag = -1;
    NSString *msgaInfo = @"";
    
    // Get msg
    regex = @"Msg=(.+?);";
    range = [resultString rangeOfString:regex options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        msgaInfo = [[[resultString substringWithRange:range] substringFromIndex:4] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'"]];
        msgFlag = [msgaInfo integerValue];
    }
    
    // Get msga
    regex = @"msga=(.+?);";
    range = [resultString rangeOfString:regex options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        // Remove msga=' and ';
        msgaInfo = [[resultString substringWithRange:range] substringFromIndex:6];
        msgaInfo = [msgaInfo stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"';"]];
        NSLog(@"%@", msgaInfo);
    }
    
    // Choose error type and make message
    NSString *errorMsg;
    switch (msgFlag) {
        case 0:
        case 1:
            if ((msgFlag==1) && ![msgaInfo isEqualToString:@""]) {
                NSLog(@"msgaInfo : %@", msgaInfo);
                if ([msgaInfo isEqualToString:@"error0"]) {
                    errorMsg = @"本IP不允许Web方式登录";
                } else if ([msgaInfo isEqualToString:@"error1"]) {
                    errorMsg = @"本账号不允许Web方式登录";
                } else if ([msgaInfo isEqualToString:@"error2"]) {
                    errorMsg = @"本账号不允许修改密码";
                } else {
                    if([msgaInfo isEqualToString:@"ldap auth error"]) {
                        // The "ldap auth error" situation
                        errorMsg = @"账号或密码不对，请检查";
                    } else {
                        errorMsg = @"未知错误";
                    }
                }
            } else {
                errorMsg = @"账号或密码不对，请检查";
            }
            break;
        case 2:
            errorMsg = @"账号正在使用";
            break;
        case 3:
            errorMsg = @"本账号只能在指定地址使用";
            break;
        case 4:
            errorMsg = @"本账号费用超支或时长流量超过限制";
            break;
        case 5:
            errorMsg = @"本账号暂停使用";
            break;
        case 6:
            errorMsg = @"服务器错误";
            break;
        case 7:
            errorMsg = @"未知错误";
            NSLog(@"login error : case 7");
            break;
        case 8:
            errorMsg = @"本账号正在使用,不能修改";
            break;
        case 9:
            errorMsg = @"新密码与确认新密码不匹配,不能修改";
            break;
        case 10:
            errorMsg = @"密码修改成功";
            break;
        case 11:
            errorMsg = @"本账号只能在指定地址使用";
            break;
        case 14:
            errorMsg = @"注销成功";
            break;
        case 15:
            errorMsg = @"登录成功";
            break;
        default:
            errorMsg = @"未知错误";
            break;
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"消息" message:errorMsg delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Device manage

- (void)doOnlineDeviceManage {
    // Get cookie and checkcode
    [self doGetCookieAndCheckcode];
    // Login will be called by doGet
}

- (void)doGetCookieAndCheckcode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [deviceManageClient getPathjSession:MANAGE_NAV_LOGIN parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        [self setCookie:operation];
        // extract checkcode for login
        NSString *regex;
        NSRange range;
        regex = @"checkcode=\"(\\d+?)\";";
        range = [result rangeOfString:regex options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            NSString *check = [[[result substringWithRange:range] substringFromIndex:11] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\";"]];
            [defaults setObject:check forKey:@"checkcode"];
            [defaults synchronize];
        }

        NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
        [defaults setObject: cookiesData forKey: @"sessionCookies"];
        [defaults synchronize];
        // Becase async ,must call post login when get return now
        [self doGetRandomCodeAction];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showNetWorkErrorAlert:nil];
    }];
}

- (void)doGetRandomCodeAction {
    NSString *randomCodeUrl = [[NSString alloc] initWithFormat:@"%@%d", MANAGE_RANDOMCODE_URL, abs(arc4random())];
    [deviceManageClient getPathjSession:randomCodeUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
        [defaults setObject: cookiesData forKey: @"sessionCookies"];
        [defaults synchronize];
        [self doPostLoginAction];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showNetWorkErrorAlert:nil];
    }];
}

- (void)doPostLoginAction {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username"];
    NSString *passwd = [defaults stringForKey:@"passwd"];
    NSString *checkcode = [defaults stringForKey:@"checkcode"];
    
    if ([LXUtil isBlankString:username] || [LXUtil isBlankString:passwd]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"用户名与密码均不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    // The request params
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:username forKey:@"account"];
    [params setObject:[LXUtil md5:passwd] forKey:@"password"];
    [params setObject:@"" forKey:@"code"];
    [params setObject:checkcode forKey:@"checkcode"];
    [params setObject:@"%E7%99%BB+%E5%BD%95" forKey:@"Submit"];
    
    [deviceManageClient postPathjSession:MANAGE_LOGIN_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
  
        NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: cookiesData forKey: @"sessionCookies"];
        [defaults synchronize];
        if ([self loginDeviceManageSuccessful:result]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccessful" object:nil];
        } else {
            [self showNetWorkErrorAlert:@"访问过程出错，请重试"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccessful" object:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showNetWorkErrorAlert:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"loginSuccessful" object:nil];
    }];
    
}

- (void)showNetWorkErrorAlert:(NSString *) message {
    NSString *innerMessage;
    if (message) {
        innerMessage = message;
    } else {
        innerMessage = @"网络错误发生，请检查连接并重试";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络错误" message:innerMessage delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)doBlanceSearch {
    AFHTTPClient *client = ([self isWiFi] ? schoolWiFiNetClient : schoolNetClient);
    [client getPath:nil parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:[LXUtil getGB2312Code]];
        NSString *testRegex = @"<title>上网注销窗</title>";
        NSRange range = [result rangeOfString:testRegex options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            [self doShowBalance:result];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先登录校园网，再进行查询。" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showNetWorkErrorAlert:nil];
    }];
}

- (void)doShowBalance:(NSString *)result {
    // First extrac data
    NSInteger time = 0;
    CGFloat flow = 0;
    CGFloat fee = 0;
    NSString *regex;
    NSRange range;
    
    regex = @"time='(.+?)';";
    range = [result rangeOfString:regex options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        NSString *tmpStr = [[[result substringWithRange:range] substringFromIndex:6] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'; \t\r\n"]];
        time = [tmpStr integerValue];
    }
    
    regex = @"flow='(.+?)';";
    range = [result rangeOfString:regex options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        NSString *tmpStr = [[[result substringWithRange:range] substringFromIndex:6] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'; \t\r\n"]];
        flow = [tmpStr integerValue];
    }
    
    regex = @"fee='(.+?)';";
    range = [result rangeOfString:regex options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        NSString *tmpStr = [[[result substringWithRange:range] substringFromIndex:5] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"'; \t\r\n"]];
        fee = [tmpStr integerValue];
    }
    
    // Format Argument
    NSString *timeStr = [[NSString alloc] initWithFormat:@"已使用时间: %i小时%i分", time/60, time%60];
    
    NSString *flowUseStr = [[NSString alloc] initWithFormat:@"已使用校外流量: %.3f Mbytes", flow/1024];
    
    NSString *balance = [[NSString alloc] initWithFormat:@"余额: %.2f RMB", (fee-fee/100)/10000];
    
    NSString *showMessage = [[NSString alloc] initWithFormat:@"%@\n%@\n%@", timeStr, flowUseStr, balance];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"流量使用情况" message:showMessage delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - Alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.cancelButtonIndex) {
        return;
    }
    if (alertView.tag == 1) {
        if ([self isWiFi]) {
            [self doSchoolWiFiNetLogin];
        } else {
            [self doSchoolNetLogin];
        }
    } else if (alertView.tag == 2) {
        if ([self isWiFi]) {
            [self doSchoolWiFiNetLogout];
        } else {
            [self doSchoolNetLogout];
        }
    }
}

+ (NSDictionary *)getIpToAddressMap {
    return ipToAddressMap;
}

+ (void)initIpToAddressMap {
    ipToAddressMap = [[NSMutableDictionary alloc] init];
    [ipToAddressMap setObject:@"教一" forKey:@"101"];
    [ipToAddressMap setObject:@"教二" forKey:@"102"];
    [ipToAddressMap setObject:@"教三" forKey:@"103"];
    [ipToAddressMap setObject:@"教四" forKey:@"104"];
    [ipToAddressMap setObject:@"主教" forKey:@"105"];
    [ipToAddressMap setObject:@"教六" forKey:@"106"];
    [ipToAddressMap setObject:@"明光楼" forKey:@"107"];
    [ipToAddressMap setObject:@"新科研楼" forKey:@"108"];
    [ipToAddressMap setObject:@"新科研楼" forKey:@"109"];
    [ipToAddressMap setObject:@"创新大本营 学十楼北地十室 综合服务楼" forKey:@"110"];
    [ipToAddressMap setObject:@"学一" forKey:@"201"];
    [ipToAddressMap setObject:@"学二" forKey:@"202"];
    [ipToAddressMap setObject:@"学三" forKey:@"203"];
    [ipToAddressMap setObject:@"学四" forKey:@"204"];
    [ipToAddressMap setObject:@"学五" forKey:@"205"];
    [ipToAddressMap setObject:@"学六" forKey:@"206"];
    [ipToAddressMap setObject:@"学七" forKey:@"207"];
    [ipToAddressMap setObject:@"学八" forKey:@"208"];
    [ipToAddressMap setObject:@"学九" forKey:@"209"];
    [ipToAddressMap setObject:@"学十" forKey:@"210"];
    [ipToAddressMap setObject:@"学十一" forKey:@"211"];
    [ipToAddressMap setObject:@"学十二" forKey:@"212"];
    [ipToAddressMap setObject:@"学十三" forKey:@"213"];
    [ipToAddressMap setObject:@"学十四" forKey:@"214"];
    [ipToAddressMap setObject:@"学二十九" forKey:@"215"];
}

#pragma mark - DEBUG USE
- (void)printManageLoginRawInfo {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults stringForKey:@"username"];
    NSString *passwd = [defaults stringForKey:@"passwd"];
    passwd = [LXUtil md5:passwd];
    NSString *cookie = [defaults stringForKey:@"JSessionCookie"];
    NSString *checkcode = [defaults stringForKey:@"checkcode"];
    NSLog(@"用户名: %@", username);
    NSLog(@"MD5密码: %@", passwd);
    NSLog(@"cookie: %@", cookie);
    NSLog(@"checkcode: %@", checkcode);
    NSLog(@"==========================");
}

- (BOOL)loginDeviceManageSuccessful:(NSString *) result {
    NSString *regex = @"在线";
    NSRange range = [result rangeOfString:regex options:NSRegularExpressionSearch];
    if (range.location != NSNotFound) {
        return YES;
    }
    return NO;
}

- (BOOL)isWiFi {
    NSString *address = [[LXUtil localWiFiIPAddress] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([address hasPrefix:@"10.8."]) {
        return YES;
    }
    NSLog(@"not wifi");
    return NO;
}

- (void)wifiTempAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"暂不支持校园网wifi接入点" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end
