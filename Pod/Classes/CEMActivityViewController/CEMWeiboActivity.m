//
//  CEMWeiboActivity.m
//  AirMonitor
//
//  Created by Sven on 3/7/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMWeiboActivity.h"
#import "CEMSocialManager.h"


@interface CEMWeiboActivity ()
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* describe;
@property (nonatomic, retain) NSString* sourceURL;
@property (nonatomic, retain) UIImage* oriImage;
@end


@implementation CEMWeiboActivity

+ (CEMActivityCategory)activityCategory {
    return CEMActivityCategoryShare;
}

- (NSString *)activityTitle {
    return @"分享到新浪微博";
}

- (NSString *)activityType {
    return CEMActivityTypePostToWeibo;
}

- (UIImage *)activityImage {
    NSBundle* sourceBundle = [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:@"Resource" ofType:@"bundle"]];
    NSString* file = [sourceBundle pathForResource:@"img_ss_wb@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:file];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    if (![CEMSocialManager weiboInstalled]) return NO;
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id object in activityItems) {
        if ([object isKindOfClass:NSString.class]) {
            if (!self.title.length) {
                self.title = object;
            }
            else {
                self.describe = object;
            }
        }
        else if ([object isKindOfClass:NSURL.class]) {
            self.sourceURL = [(NSURL *)object absoluteString];
        }
        else if ([object isKindOfClass:UIImage.class]) {
            self.oriImage = object;
        }
    }
}

- (void)performActivity {
    if (self.oriImage) {
        [[CEMSocialManager sharedSocialManager] sendToWeiboClientWithMedia:self.oriImage text:self.describe];
    }
    else  {
        [[CEMSocialManager sharedSocialManager] sendToWeiboClientWithMedia:self.sourceURL
                                                                     title:self.title
                                                               description:self.describe
                                                                   preview:nil];
    }
    
    [self activityDidFinish:YES];
}

@end
