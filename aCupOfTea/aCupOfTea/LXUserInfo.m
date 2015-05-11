//
//  LXUserInfo.m
//  aCupOfTea
//
//  Created by mwsn on 14-12-26.
//  Copyright (c) 2014年 Sangoly. All rights reserved.
//

#import "LXUserInfo.h"

@implementation LXUserInfo

- (NSArray *)getUserInfoKeyArray {
    NSMutableArray *userinfo = [[NSMutableArray alloc] init];
    [userinfo addObject:@"余额(元)"];
    [userinfo addObject:@"本月时长"];
    [userinfo addObject:@"本月流量(MB)"];
    [userinfo addObject:@"计费(元)"];
    [userinfo addObject:@"用户类别"];
    [userinfo addObject:@"安装地址"];
    [userinfo addObject:@"布线资料"];
    [userinfo addObject:@"联系电话1"];
    [userinfo addObject:@"联系电话2"];
    [userinfo addObject:@"证件号码"];
    [userinfo addObject:@"电子邮箱"];
    [userinfo addObject:@"账单地址"];
    [userinfo addObject:@"失效日期"];
    return userinfo;
}

- (NSArray *)getUserInfoValueArray {
    NSMutableArray *userinfoValue = [[NSMutableArray alloc] init];
    [userinfoValue addObject:_balance];
    [userinfoValue addObject:_time];
    [userinfoValue addObject:_flow];
    [userinfoValue addObject:_timeFlowRatio];
    [userinfoValue addObject:_categoery];
    [userinfoValue addObject:_address];
    [userinfoValue addObject:_setupInfo];
    [userinfoValue addObject:_telOne];
    [userinfoValue addObject:_telTwo];
    [userinfoValue addObject:_cardID];
    [userinfoValue addObject:_email];
    [userinfoValue addObject:_billAddress];
    [userinfoValue addObject:_expiredDate];
    return userinfoValue;
}

@end
