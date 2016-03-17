//
//  CEMActivity+Private.m
//  AirMonitor
//
//  Created by Sven on 3/7/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMActivity+Private.h"

#import "CEMWeChatActivity.h"
#import "CEMWeiboActivity.h"
#import "CEMQQActivity.h"
#import "CEMRefreshActivity.h"
#import "CEMMessageActivity.h"
#import "CEMSafariActivity.h"

///
static NSDictionary * _activityClsAndTypeMappingDic = nil;

@implementation CEMActivity (Private)
@dynamic delegate;


+ (void)load {
    if (self == CEMActivity.class) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _activityClsAndTypeMappingDic = @{ CEMActivityTypePostToWeChat: CEMWeChatActivity.class,
                                               CEMActivityTypePostToWeChatTimeline: CEMWeChatTimelineActivity.class,
                                               CEMActivityTypePostToQQ: CEMQQActivity.class,
                                               CEMActivityTypePostToQzone: CEMQQzoneActivity.class,
                                               CEMActivityTypePostToWeibo: CEMWeiboActivity.class,
                                               CEMActivityTypeMessage: CEMMessageActivity.class,
                                               CEMActivityTypeMail: CEMMailActivity.class,
                                               CEMActivityTypeRefreshWeb: CEMRefreshActivity.class,
                                               CEMActivityTypeOpenInSafari: CEMSafariActivity.class,
                                               };
        });
    }
}

#pragma mark __PRI__
+ (instancetype)activityWithType:(NSString *)type {
    if (!type) return nil;
    
    Class activityCls = _activityClsAndTypeMappingDic[type];
    if (!activityCls) return nil;
    return [[activityCls alloc] init];
}

@end
