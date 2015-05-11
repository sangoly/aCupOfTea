//
//  LXFirstViewController.m
//  aCupOfTea
//
//  Created by mwsn on 14-12-18.
//  Copyright (c) 2014年 Sangoly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXAppDelegate.h"
#import "LXRootViewController.h"
#import "LXUtil.h"
#import "LXNetLoginViewController.h"
#import "LXSchoolNetManager.h"
#import "LXDeviceManageControllerViewController.h"

@interface LXRootViewController ()
{
    NSArray *ma;
    UISwitch *sw;
    LXSchoolNetManager *schoolNetManager;
}
@end

@implementation LXRootViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.navi = [[UINavigationController alloc] initWithRootViewController:self];
        if ([LXUtil IS_IOS_7_OR_LATER]) {
            self.navi.navigationBar.barTintColor = [UIColor brownColor];
        } else {
            self.navi.navigationBar.tintColor = [UIColor brownColor];
        }
//        self.navi.navigationBar.tintColor = [UIColor brownColor];
        self.title = @"列表";
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_setting.png"] style:UIBarButtonItemStylePlain target:self action:@selector(settingButtonDidClicked:)];
        self.navigationItem.rightBarButtonItem = barButtonItem;
        // Init schoolNetManager
        schoolNetManager = [[LXSchoolNetManager alloc] init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if ([defaults objectForKey:@"checkcode"]) {
            [defaults removeObjectForKey:@"checkcode"];
        }
        [defaults synchronize];
    }
    return self;
}

// Add the init constructor - sangoly
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Regist long click event
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longSelectDidHandler:)];
    lpgr.minimumPressDuration = 1.0;
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
    
    // Sync with setting view
    if (sw) {
        [sw setOn:[[NSUserDefaults standardUserDefaults] boolForKey:@"force_login"]];
    }
    
    // If user first login then pop up wzard
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL zwardComplete = [defaults boolForKey:@"zwardComplete"];
    if (!zwardComplete) {
        LXNetLoginViewController *wzardController = [[LXNetLoginViewController alloc] init];
        [self.navi presentViewController:wzardController animated:YES completion:nil];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Init test array data
    ma = [[NSArray alloc] initWithObjects:@"校园网登录", @"校园网注销", @"在线IP管理",@"余额查询", nil];
    
    // Regist the cell reuse identifier
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Cell long time click

- (void)longSelectDidHandler:(UILongPressGestureRecognizer *) gestureRecognizer {
    // Remove it , ensure only one gesture can be recognized
    [self.tableView removeGestureRecognizer:gestureRecognizer];
    CGPoint p = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    if (indexPath.section == 0 && indexPath.row == 0) {
        LXNetLoginViewController *settingView = [[LXNetLoginViewController alloc] init];
        [self.navi pushViewController:settingView animated:YES];
    }
}

- (void)settingButtonDidClicked:(UIBarButtonItem *)sender {
    LXNetLoginViewController *settingView = [[LXNetLoginViewController alloc] init];
    [self.navi pushViewController:settingView animated:YES];
}

- (void)switchStatusChanged:(UISwitch *) sender {
    BOOL forceLogin = (sender.on == 1) ? YES : NO;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:forceLogin forKey:@"force_login"];
    [defaults synchronize];
}


- (void)showDeviceManageDetailView:(NSString *)userInfo {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"loginSuccessful" object:nil];
    if (userInfo) {
        LXDeviceManageControllerViewController *deviceManagerController = [[LXDeviceManageControllerViewController alloc] init];
        [self.navi pushViewController:deviceManagerController animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [ma count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    /**
     * There may be waste in cell because of no reusing
     */
    
    UITableViewCell *cell = cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    [cell setHighlighted:YES animated:YES];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.section == 0) {
        cell.textLabel.text = [ma objectAtIndex:indexPath.row];
    }
    // Make the accessoryType
    if (indexPath.section == 0 && indexPath.row == 0) {
        // If the wifi login row, make the accessory view with switch view
        sw = [[UISwitch alloc] init];
        [sw addTarget:self action:@selector(switchStatusChanged:) forControlEvents:UIControlEventValueChanged];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        BOOL forceLogin = [defaults boolForKey:@"force_login"];
        [sw setOn:forceLogin];
        cell.detailTextLabel.text = @"强制登录";
        cell.accessoryView = sw;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            // Add observer
            if ([self respondsToSelector:@selector(showDeviceManageDetailView:)]) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDeviceManageDetailView:) name:@"loginSuccessful" object:nil];
            }
            [schoolNetManager doSchoolNetWorkOperator:indexPath.row];
            break;
        case 1:
            break;
        default:
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"校园网";
    } else {
        return @"第二个";
    }
}

@end