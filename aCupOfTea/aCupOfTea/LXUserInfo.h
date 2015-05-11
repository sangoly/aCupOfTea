//
//  LXUserInfo.h
//  aCupOfTea
//
//  Created by mwsn on 14-12-26.
//  Copyright (c) 2014年 Sangoly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LXUserInfo : NSObject

@property (strong, nonatomic) NSString *balance;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *flow;
@property (strong, nonatomic) NSString *timeFlowRatio;
@property (strong, nonatomic) NSString *categoery;
@property (strong, nonatomic) NSString *address;
@property (strong, nonatomic) NSString *setupInfo;
@property (strong, nonatomic) NSString *telOne;
@property (strong, nonatomic) NSString *telTwo;
@property (strong, nonatomic) NSString *cardID;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) NSString *billAddress;
@property (strong, nonatomic) NSString *expiredDate;

- (NSArray *) getUserInfoKeyArray;
- (NSArray *) getUserInfoValueArray;

@end
