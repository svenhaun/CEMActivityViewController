//
//  CEMSafariActivity.m
//  AirMonitor
//
//  Created by Sven on 3/8/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMSafariActivity.h"
#import "CEMUtilities.h"


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
    return [UIImage cem_imageNamed:@"safari"];
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
