//
//  CEMWeChatActivity.m
//  AirMonitor
//
//  Created by Sven on 3/7/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMWeChatActivity.h"
#import "CEMSocialManager.h"
#import "CEMUtilities.h"


@interface CEMWeChatActivity ()
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* describe;
@property (nonatomic, retain) NSString* sourceURL;
@property (nonatomic, retain) UIImage* oriImage;
@end

@implementation CEMWeChatActivity

+ (CEMActivityCategory)activityCategory {
    return CEMActivityCategoryShare;
}

- (NSString *)activityTitle {
    return @"发送给微信好友";
}

- (NSString *)activityType {
    return CEMActivityTypePostToWeChat;
}

- (UIImage *)activityImage {
    return [UIImage cem_imageNamed:@"img_ss_wechat" inBundle:@"Resource"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    if (![CEMSocialManager winxinInstalled]) return NO;
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
    if (self.isFile && self.fileData) {
        [[CEMSocialManager sharedSocialManager] sendToTencentSession:CEMSocialPlatformTencentWeChatSession
                                                            withFile:self.fileData
                                                           extension:self.fileType];
    }
    else {
        if (self.sourceURL) {
            NSData* previewData = UIImageJPEGRepresentation(self.oriImage, 0.1);
            UIImage* preview;
            if (previewData) preview = [UIImage imageWithData:previewData];
            
            [[CEMSocialManager sharedSocialManager] sendToTencentSession:CEMSocialPlatformTencentWeChatSession sourceURL:self.sourceURL
                                                                   title:self.title description:self.describe
                                                                 preview:preview];
        }
        else if (self.oriImage) {
            [[CEMSocialManager sharedSocialManager] sendToTencentSession:CEMSocialPlatformTencentWeChatSession withImage:self.oriImage];
        }
        else  {
            [[CEMSocialManager sharedSocialManager] sendToTencentSession:CEMSocialPlatformTencentWeChatSession
                                                                withText:self.title ?: self.describe];
        }
    }
    
    [self activityDidFinish:YES];
}

@end


////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////         Friends Circle            ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface CEMWeChatTimelineActivity ()
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* describe;
@property (nonatomic, retain) NSString* sourceURL;
@property (nonatomic, retain) UIImage* oriImage;
@end


@implementation CEMWeChatTimelineActivity

+ (CEMActivityCategory)activityCategory {
    return CEMActivityCategoryShare;
}

- (NSString *)activityTitle {
    return @"分享到微信朋友圈";
}

- (NSString *)activityType {
    return CEMActivityTypePostToWeChatTimeline;
}

- (UIImage *)activityImage {
    return [UIImage cem_imageNamed:@"img_ss_wechat_friendcircle" inBundle:@"Resource"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    if (![CEMSocialManager winxinInstalled]) return NO;
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
    if (self.sourceURL) {
        NSData* previewData = UIImageJPEGRepresentation(self.oriImage, 0.1);
        UIImage* preview;
        if (previewData) preview = [UIImage imageWithData:previewData];
        
        [[CEMSocialManager sharedSocialManager] sendToTencentTimeline:CEMSocialPlatformTencentWeChatTimeline sourceURL:self.sourceURL
                                                                title:self.title description:self.describe
                                                              preview:preview];
    }
    else {
        [[CEMSocialManager sharedSocialManager] sendToWechatTimelineWithSource:self.oriImage title:self.title
                                                                   description:self.describe];
    }
    
    [self activityDidFinish:YES];
}


@end
