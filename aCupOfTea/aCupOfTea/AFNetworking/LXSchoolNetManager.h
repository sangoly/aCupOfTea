//
//  LXSchoolNetManager.h
//  aCupOfTea
//
//  Created by mwsn on 14-12-22.
//  Copyright (c) 2014年 Sangoly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClient.h"

@interface LXSchoolNetManager : NSObject

- (id)init;

#pragma mark - operator funtions
- (void)doSchoolNetWorkOperator:(NSInteger) row;

#pragma mark - login logout and search
- (void)doSchoolNetLogin;
- (void)doSchoolNetLogout;
- (void)doBlanceSearch;

#pragma mark - device manager
- (void)doOnlineDeviceManage;
- (void)doGetCookieAndCheckcode;
- (void)doPostLoginAction;

#pragma mark - IP address map
+ (NSDictionary *)getIpToAddressMap;

@end
