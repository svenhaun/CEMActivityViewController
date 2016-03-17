//
//  CEMSafariActivity.m
//  AirMonitor
//
//  Created by Sven on 3/8/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMSafariActivity.h"

@interface CEMSafariActivity ()
@property (nonatomic, retain) NSURL* url;
@end


@implementation CEMSafariActivity

+ (CEMActivityCategory)activityCategory {
    return CEMActivityCategoryShare;
}

- (NSString *)activityType {
    return CEMActivityTypeOpenInSafari;
}

- (NSString *)activityTitle {
    return @"在Safari中打开";
}

- (UIImage *)activityImage {
    NSBundle* sourceBundle = [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:@"Resource" ofType:@"bundle"]];
    NSString* file = [sourceBundle pathForResource:@"safari@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:file];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:NSURL.class]
            && [[UIApplication sharedApplication] canOpenURL:activityItem]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:NSURL.class]) {
            self.url = activityItem;
        }
    }
}

- (void)performActivity {
    BOOL completed = [[UIApplication sharedApplication] openURL:self.url];
    [self activityDidFinish:completed];
}


@end
