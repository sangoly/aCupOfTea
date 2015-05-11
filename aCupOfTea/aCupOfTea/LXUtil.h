//
//  LXUtil.h
//  aCupOfTea
//
//  Created by mwsn on 14-12-19.
//  Copyright (c) 2014年 Sangoly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LXUtil : NSObject

+ (BOOL)IS_IOS_7_OR_LATER;
+ (BOOL) isBlankString:(NSString *)string;
+ (NSStringEncoding)getGB2312Code;
+ (NSString *)md5:(NSString *)str;

+ (id)fetchSSIDInfo;
+ (NSString *) localWiFiIPAddress;

@end
