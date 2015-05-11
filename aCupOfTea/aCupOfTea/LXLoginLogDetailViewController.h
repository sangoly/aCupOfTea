//
//  LXLoginLogDetailViewController.h
//  aCupOfTea
//
//  Created by mwsn on 14-12-28.
//  Copyright (c) 2014年 Sangoly. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LXLoginLogDetailViewController : UIViewController<UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *loginLogDetailView;
@property (strong, nonatomic) NSString *url;
@property (strong, nonatomic) UIActivityIndicatorView *indicatorView;

- (id)init;

@end
