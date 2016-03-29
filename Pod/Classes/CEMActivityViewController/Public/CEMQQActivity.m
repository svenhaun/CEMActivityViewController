//
//  CEMQQActivity.m
//  AirMonitor
//
//  Created by Sven on 3/7/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMQQActivity.h"
#import "CEMSocialManager.h"
#import "CEMUtilities.h"


@interface CEMQQActivity ()
@end

@implementation CEMQQActivity

+ (CEMActivityCategory)activityCategory {
    return CEMActivityCategoryShare;
}

- (NSString *)activityTitle {
    return @"发送给QQ好友";
}

- (NSString *)activityType {
    return CEMActivityTypePostToQQ;
}

- (UIImage *)activityImage {
    return [UIImage cem_imageNamed:@"img_ss_qq"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
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
//    if (self.isFile && self.fileData) {
//        [[CEMSocialManager sharedSocialManager] sendToTencentSession:CEMSocialPlatformTencentQQSession
//                                                            withFile:self.fileData
//                                                           extension:self.fileType];
//    }
//    else {
        if (self.sourceURL) {
            NSData* previewData = UIImageJPEGRepresentation(self.oriImage, 0.1);
            UIImage* preview;
            if (previewData) preview = [UIImage imageWithData:previewData];
            
            [[CEMSocialManager sharedSocialManager] sendToTencentSession:CEMSocialPlatformTencentQQSession sourceURL:self.sourceURL
                                                                   title:self.title description:self.describe
                                                                 preview:preview];
        }
        else if (self.oriImage) {
            [[CEMSocialManager sharedSocialManager] sendToTencentSession:CEMSocialPlatformTencentQQSession withImage:self.oriImage];
        }
        else  {
            [[CEMSocialManager sharedSocialManager] sendToTencentSession:CEMSocialPlatformTencentQQSession
                                                                withText:self.title ?: self.describe];
        }
//    }
    
    [self activityDidFinish:YES];
}

@end



////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////             QQzone              ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface CEMQQzoneActivity ()
@property (nonatomic, retain) NSString* sourceURL;
@end

///
@implementation CEMQQzoneActivity

+ (CEMActivityCategory)activityCategory {
    return CEMActivityCategoryShare;
}

- (NSString *)activityTitle {
    return @"分享到QQ空间";
}

- (NSString *)activityType {
    return CEMActivityTypePostToQzone;
}

- (UIImage *)activityImage {
    return [UIImage cem_imageNamed:@"img_ss_qqzone"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (NSObject* object in activityItems) {
        if ([object.class isSubclassOfClass:NSURL.class]) {
            return YES;
        }
    }
    
    return NO;
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
            self.previewImage = object;
        }
    }
}

- (void)performActivity {
    [[CEMSocialManager sharedSocialManager] sendToTencentTimeline:CEMSocialPlatformTencentQQZoneTimeline sourceURL:self.sourceURL
                                                            title:self.title description:self.describe
                                                          preview:self.previewImage];
 
    [self activityDidFinish:YES];
}

@end

