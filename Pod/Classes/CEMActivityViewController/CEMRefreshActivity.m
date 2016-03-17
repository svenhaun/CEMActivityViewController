//
//  CEMRefreshActivity.m
//  AirMonitor
//
//  Created by Sven on 3/7/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMRefreshActivity.h"

@implementation CEMRefreshActivity

+ (CEMActivityCategory)activityCategory {
    return CEMActivityCategoryAction;
}

- (NSString *)activityTitle {
    return @"刷新";
}

- (NSString *)activityType {
    return CEMActivityTypeRefreshWeb;
}

- (UIImage *)activityImage {
    NSBundle* sourceBundle = [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:@"Resource" ofType:@"bundle"]];
    NSString* file = [sourceBundle pathForResource:@"Refresh@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:file];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (NSObject* obj in activityItems) {
        if ([obj.class isSubclassOfClass:NSURL.class]) {
            return YES;
        }
    }
    
    return NO;
}

@end
