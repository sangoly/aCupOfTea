//
//  LXDeviceManageControllerViewController.m
//  aCupOfTea
//
//  Created by mwsn on 14-12-23.
//  Copyright (c) 2014年 Sangoly. All rights reserved.
//

#import "LXDeviceManageControllerViewController.h"
#import "LXUserInfoView.h"
#import "LXPersonalDetailController.h"
#import "LXLoginLogDetailViewController.h"
#import "LXSchoolNetManager.h"
#import "LXUtil.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "TFHpple.h"
#import "TFHppleElement.h"
#import "XPathQuery.h"
#import "Toast+UIView.h"

#define MANAGE_BASE_URL @"http://gwself.bupt.edu.cn"
#define MANAGE_ACCOUNT_INFO_URL @"refreshaccount?t="
#define MANAGE_USER_LOGINLOG_URL @"UserLoginLogAction.action"
#define MANAGE_ONLINE_DEVICE_URL @"nav_offLine"
#define MANAGE_FORCE_OFFLINE_URL @"tooffline?t=2348739824&fldsessionid=" // ip
#define MANAGE_GET_USERINFO_URL @"nav_getUserInfo"
#define MANAGE_NAV_MONTHPAY @"http://gwself.bupt.edu.cn/nav_monthPay"
#define MANAGE_NAV_OPERATORLOG @"http://gwself.bupt.edu.cn/nav_operatorLog"
#define MANAGE_NAV_LOGINLOG @"http://gwself.bupt.edu.cn/nav_loginLog"
#define MANAGE_NAV_PAYMENET @"http://gwself.bupt.edu.cn/nav_Payment"

#define MARGIN_LEFT_RIGHT 40.0f
#define PADDING_TOP 100.0f
#define MARGIN_TOP 30.0f
#define LABLE_HEIGHT 25.0F

/**
 * 1、基本信息显示
 * 2、在线IP管理
 * 3、账单查询
 * 4、登录记录查询
 */


@interface LXDeviceManageControllerViewController ()
{
    AFHTTPClient *manageClient;
    NSDictionary *infoNameMap;
    NSMutableDictionary *userinfo;
    NSString *serverDate;
    NSArray* sessionIDElements;
}
@end

@implementation LXDeviceManageControllerViewController

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"设备管理";
        UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet:)];
        self.navigationItem.rightBarButtonItem = buttonItem;
        
        manageClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:MANAGE_BASE_URL]];
        infoNameMap = [NSDictionary dictionaryWithObjectsAndKeys:@"余      额", @"leftmoeny", @"在线状态", @"onlinestate", @"过      期", @"overdate", @"服       务", @"service", @"使用状态", @"status", @"用      户", @"welcome", nil];
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"backgroud@2x.jpg"]];
    
    [manageClient getPathjSession:MANAGE_ACCOUNT_INFO_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *errors;
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&errors];
        if (dict && !errors) {
            serverDate = [dict objectForKey:@"serverDate"];
            [self initLayoutViews:[dict objectForKey:@"note"]];
        } else {
            NSLog(@"wrong");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"lxDeviceController - error");
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showActionSheet:(UIBarButtonItem *)sender {
    // @"显示使用记录", @"显示消费记录"
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"操作" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"管理在线设备" otherButtonTitles:@"详细个人资料",@"查询上网详单",@"查询扣费详单",@"业务办理记录",@"交费情况记录", nil];
    actionSheet.tag = 1;
    actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
    [actionSheet showInView:self.view];
}

- (void)initLayoutViews:(NSMutableDictionary *)dict {
    
    // Change value to readable string
    NSInteger online = [[dict objectForKey:@"onlinestate"] integerValue];
    if (online == 1) {
        [dict setObject:@"在线" forKey:@"onlinestate"];
    } else {
        [dict setObject:@"离线" forKey:@"onlinestate"];
    }
    
    NSString *status = [dict objectForKey:@"status"];
    if ([status isEqualToString:@"Enabled"]) {
        [dict setObject:@"可用" forKey:@"status"];
    } else {
        [dict setObject:@"不可用" forKey:@"status"];
    }
    
    NSString *overdate = [dict objectForKey:@"overdate"];
    if ([LXUtil isBlankString:overdate]) {
        [dict setObject:@"否" forKey:@"overdate"];
    }
    
    int i = 0;
    for (id key in dict) {
        NSString *rightLabelText = [dict objectForKey:key];
        NSString *leftLabelText = [infoNameMap objectForKey:key];
        [self.view addSubview:[self makeUserInfoSubView:85.0+i*60.0 leftLabel:leftLabelText rightLabel:rightLabelText]];
        i++;
    }
}

- (LXUserInfoView *)makeUserInfoSubView:(CGFloat)height leftLabel:(NSString *)labell rightLabel:(NSString *)labelr {
    labell = [[NSString alloc] initWithFormat:@"%@:  ", labell];
    LXUserInfoView *infoView = [[LXUserInfoView alloc] initWithFrame:CGRectMake(30.0f, height, self.view.bounds.size.width-2*30.0f, 50.0f) leftLabel:labell     rightViewText:labelr labelOrButton:1];
    return infoView;
}

- (void)forceOfflineButtonClicked {
    // First get online device
    [manageClient getPathjSession:MANAGE_ONLINE_DEVICE_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray *elements = [doc searchWithXPathQuery:@"//tbody//tr//td[1]"];
        sessionIDElements = [doc searchWithXPathQuery:@"//tbody//tr//td[4]"];
     
        if ([elements count] == 1) {
            NSString *ipOne = [(TFHppleElement *)[elements objectAtIndex:0] text];
            UIActionSheet *forceOfflineSheet = [[UIActionSheet alloc] initWithTitle:@"强迫离线" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:[self makeOnlineIpMapString:ipOne]  otherButtonTitles:nil, nil];
            forceOfflineSheet.tag = 2;
            [forceOfflineSheet showInView:self.view];
        } else if ([elements count] == 2) {
            NSString *ipOne = [(TFHppleElement *)[elements objectAtIndex:0] text];
            NSString *ipTwo = [(TFHppleElement *)[elements objectAtIndex:1] text];
            UIActionSheet *forceOfflineSheet = [[UIActionSheet alloc] initWithTitle:@"强迫离线" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:[self makeOnlineIpMapString:ipOne]  otherButtonTitles:[self makeOnlineIpMapString:ipTwo], nil];
            forceOfflineSheet.tag = 2;
            [forceOfflineSheet showInView:self.view];
        } else {
            id pos = [NSValue valueWithCGPoint:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)];
            [self.view makeToast:@"当前没有在线IP" duration:2.0f position:pos];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showNetWorkErrorAlert:nil];
    }];
}

- (NSString *)makeOnlineIpMapString:(NSString *)ipElement {
    NSDictionary *ipToAddressMap = [LXSchoolNetManager getIpToAddressMap];
    NSString *ipStr = [ipElement substringToIndex:([ipElement length]-1)];
    if ([ipStr hasPrefix:@"10.8."]) {
        return [[NSString alloc] initWithFormat:@"%@(%@)", ipStr, @"无线"];
    }
    NSString *locator = [[ipStr componentsSeparatedByString:@"."] objectAtIndex:1];
    NSString *address = [ipToAddressMap objectForKey:locator];
    if (address) {
        return [[NSString alloc] initWithFormat:@"%@(%@)", ipStr, address];
    }
    return [[NSString alloc] initWithFormat:@"%@(%@)", ipStr, @"未知位置"];
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

- (void)forceOfflineWithSessionID:(NSString *)sessionID {
    NSString *forceOfflineUrl = [[NSString alloc] initWithFormat:@"%@%@", MANAGE_FORCE_OFFLINE_URL, sessionID];
    [manageClient getPathjSession:forceOfflineUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *result = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        if (result) {
//            {"date":"success","note":null,"outmessage":"true","serverDate":"2014-12-24"}
            NSError *errors;
            NSDictionary *forceOfflineFeedback = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&errors];
            if (forceOfflineFeedback && !errors) {
                if ([[forceOfflineFeedback objectForKey:@"date"] isEqualToString:@"success"]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"通知" message:@"强制离线成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                } else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"通知" message:@"强制离线失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alert show];
                }
            } else {
                NSLog(@"error force online feedback");
            }
                                                  
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showNetWorkErrorAlert:nil];
        NSLog(@"%@", error);
    }];
}

- (void) showPersonDetailView {
    [manageClient getPathjSession:MANAGE_GET_USERINFO_URL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Generate userinfo
        TFHpple *doc = [[TFHpple alloc] initWithHTMLData:responseObject];
        NSArray *elements = [doc searchWithXPathQuery:@"//table//tr//td[@class='t_r1']"];
        
        LXUserInfo *personalDetail = [[LXUserInfo alloc] init];
        TFHppleElement *balanceElement = [elements objectAtIndex:0];
        NSArray *balanceChildren = [balanceElement childrenWithTagName:@"font"];
        if (balanceChildren) {
            personalDetail.balance = [self getPurelText:[(TFHppleElement *)[balanceChildren objectAtIndex:0] text]];
        } else {
            [self getPurelText:[(TFHppleElement *)[elements objectAtIndex:0] text]];
        }
        personalDetail.time = [self getPurelText:[(TFHppleElement *)[elements objectAtIndex:1] text]];
        CGFloat flowTotal = [[self getPurelText:[(TFHppleElement *)[elements objectAtIndex:2] text]] floatValue];
        NSInteger baseFlow = (NSInteger)flowTotal;
        personalDetail.flow = [[NSString alloc] initWithFormat:@"%i G %.3f M", baseFlow/1024, flowTotal-baseFlow/1024*1024];
        
        personalDetail.timeFlowRatio = [self getPurelText:[(TFHppleElement *)[elements objectAtIndex:3] text]];
        personalDetail.categoery = [self getPurelText:[(TFHppleElement *)[elements objectAtIndex:4] text]];
        personalDetail.address = [self getPurelText:[(TFHppleElement *)[elements objectAtIndex:5] text]];
        personalDetail.setupInfo = [self getPurelText:[(TFHppleElement *)[elements objectAtIndex:6] text]];
        personalDetail.telOne = [self getPurelText:[(TFHppleElement *)[elements objectAtIndex:7] text]];
        personalDetail.telTwo = [self getPurelText:[(TFHppleElement *)[elements objectAtIndex:8] text]];
        personalDetail.cardID = [self getPurelText:[(TFHppleElement *)[elements objectAtIndex:9] text]];
        personalDetail.email = [self getPurelText:[(TFHppleElement *)[elements objectAtIndex:10] text]];
        personalDetail.billAddress = [self getPurelText:[(TFHppleElement *)[elements objectAtIndex:11] text]];
        personalDetail.expiredDate = [self getPurelText:[(TFHppleElement *)[elements objectAtIndex:12] text]];
        
        LXPersonalDetailController *personalDetailController = [[LXPersonalDetailController alloc] init];
        personalDetailController.personalDetailKeys = [personalDetail getUserInfoKeyArray];
        personalDetailController.personalDetailValues = [personalDetail getUserInfoValueArray];
        [self.navigationController pushViewController:personalDetailController animated:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showNetWorkErrorAlert:nil];
    }];
}

- (NSString *)getPurelText:(NSString*) rawString {
    NSString *result = [rawString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![LXUtil isBlankString:result]) {
        return result;
    }
    return @"N/A";
}

- (void)showDetailWebView:(NSString *)targetUrl {
    LXLoginLogDetailViewController *loginLogDetail = [[LXLoginLogDetailViewController alloc] init];
    loginLogDetail.url = targetUrl;
    [self.navigationController pushViewController:loginLogDetail animated:YES];
}

#pragma mark - UIActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 0:
                [self forceOfflineButtonClicked];
                break;
            case 1:
                [self showPersonDetailView];
                break;
            case 2:
                [self showDetailWebView:MANAGE_NAV_LOGINLOG];
                break;
            case 3:
                [self showDetailWebView:MANAGE_NAV_MONTHPAY];
                break;
            case 4:
                [self showDetailWebView:MANAGE_NAV_OPERATORLOG];
                break;
            case 5:
                [self showDetailWebView:MANAGE_NAV_PAYMENET];
                break;
            default:
                break;
        }
    } else if (actionSheet.tag == 2) {
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            NSString *sessionID = [(TFHppleElement *)[sessionIDElements objectAtIndex:buttonIndex] text];
            [self forceOfflineWithSessionID:sessionID];
        }
    }
}

@end
