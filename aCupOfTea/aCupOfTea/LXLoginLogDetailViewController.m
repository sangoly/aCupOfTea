//
//  LXLoginLogDetailViewController.m
//  aCupOfTea
//
//  Created by mwsn on 14-12-28.
//  Copyright (c) 2014年 Sangoly. All rights reserved.
//

#import "LXLoginLogDetailViewController.h"

@interface LXLoginLogDetailViewController ()

@end

@implementation LXLoginLogDetailViewController

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Set toolbar item
    UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *home = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_home.png"] style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonDidClicked:)];
    self.toolbarItems = [NSArray arrayWithObjects:flexibleSpaceButtonItem, home, flexibleSpaceButtonItem, nil];
    
    // Set webview
    _loginLogDetailView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _loginLogDetailView.delegate = self;
    _loginLogDetailView.scalesPageToFit = YES;
    [self.view addSubview:_loginLogDetailView];
    
    // Set indicator view
    _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
    [_indicatorView setCenter:self.view.center];
    [_indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    [self.view addSubview:_indicatorView];
    
    // Load data from url
    NSURL *requestUrl = [NSURL URLWithString:_url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestUrl];
    [request setValue:@"zh-CN,zh;q=0.8" forHTTPHeaderField:@"Accept-Language"];
    [_loginLogDetailView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - home button response function

- (void)homeButtonDidClicked:(UIBarButtonItem *)sender {
    [_loginLogDetailView goBack];
}

#pragma mark - UIWebView delegate

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [_indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"load detail login log error: %@", error);
    // If load error, just back to device manage page
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"加载登录详细信息出错，请检查网络再试" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    if (item.tag == 1) {
        NSLog(@"home selected");
    }
}

@end
