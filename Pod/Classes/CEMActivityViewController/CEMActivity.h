//
//  CEMActivity.h
//  AirMonitor
//
//  Created by Sven on 3/7/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const CEMActivityTypePostToWeibo;         // SinaWeibo
extern NSString *const CEMActivityTypePostToWeChat;        // wexin
extern NSString *const CEMActivityTypePostToWeChatTimeline;// pengyouquan
extern NSString *const CEMActivityTypePostToQQ;            //
extern NSString *const CEMActivityTypePostToQzone;

extern NSString *const CEMActivityTypeOpenInSafari;
extern NSString *const CEMActivityTypeMessage;
extern NSString *const CEMActivityTypeMail;

// actions
extern NSString *const CEMActivityTypeRefreshWeb;
extern NSString *const CEMActivityTypeTrash;
extern NSString *const CEMActivityTypeFavorite;
extern NSString *const CEMActivityTypeIllegalReport;
extern NSString *const CEMActivityTypeSaveToLocal;


typedef enum : NSUInteger {
    CEMActivityCategoryAction,
    CEMActivityCategoryShare,
} CEMActivityCategory;


@interface CEMActivity : NSObject

+ (CEMActivityCategory)activityCategory; // default is CEMActivityCategoryAction.

- (nullable NSString *)activityType;       // default returns nil. subclass may override to return custom activity type that is reported to completion handler
- (nullable NSString *)activityTitle;      // default returns nil. subclass must override and must return non-nil value
- (nullable UIImage *)activityImage;       // default returns nil. subclass must override and must return non-nil value

- (BOOL)canPerformWithActivityItems:(nullable NSArray *)activityItems;   // override this to return availability of activity based on items. default returns NO
- (void)prepareWithActivityItems:(nullable NSArray *)activityItems;      // override to extract items and set up your HI. default does nothing

- (nullable UIViewController *)activityViewController;   // return non-nil to have view controller presented modally. call activityDidFinish at end. default returns nil
- (void)performActivity;                        // if no view controller, this method is called. call activityDidFinish when done. default calls [self activityDidFinish:NO]

// state method

- (void)activityDidFinish:(BOOL)completed;   // activity must call this when activity is finished
@end


NS_ASSUME_NONNULL_END