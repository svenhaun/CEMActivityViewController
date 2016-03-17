//
//  CEMActivity.m
//  AirMonitor
//
//  Created by Sven on 3/7/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMActivity.h"
#import "CEMActivity+Private.h"

NSString *const CEMActivityTypePostToWeibo              = @"com.cem.activity.PostToWeibo";              // SinaWeibo
NSString *const CEMActivityTypePostToWeChat             = @"com.cem.activity.PostToWeChat";             // wexin
NSString *const CEMActivityTypePostToWeChatTimeline     = @"com.cem.activity.PostToWeChat_Timeline";    // pengyouquan
NSString *const CEMActivityTypePostToQQ                 = @"com.cem.activity.PostToQQ";                 //
NSString *const CEMActivityTypePostToQzone              = @"com.cem.activity.PostToQzone";

NSString *const CEMActivityTypeOpenInSafari             = @"com.cem.activity.OpenInSafari";
NSString *const CEMActivityTypeMessage                  = @"com.cem.activity.Message";
NSString *const CEMActivityTypeMail                     = @"com.cem.activity.Mail";

NSString *const CEMActivityTypeRefreshWeb               = @"com.cem.activity.Refresh";


@interface CEMActivity ()
@property (nonatomic, weak) id<CEMActivityDelegate> delegate;
@end

///
@implementation CEMActivity
//@dynamic delegate;

//
+ (CEMActivityCategory)activityCategory { // default is CEMActivityCategoryAction.
    return CEMActivityCategoryAction;
}

// default returns nil. subclass may override to return custom activity type that is reported to
//completion handler
- (nullable NSString *)activityType {
    return nil;
}

- (nullable NSString *)activityTitle { return nil; }      // default returns nil. subclass must override and must return non-nil value
- (nullable UIImage *)activityImage { return nil; }       // default returns nil. subclass must override and must return non-nil value

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems { return NO; }   // override this to return availability of activity based on items. default returns NO
- (void)prepareWithActivityItems:(NSArray *)activityItems {}      // override to extract items and set up your HI. default does nothing

// return non-nil to have view controller presented modally. call activityDidFinish at end. default returns nil
- (nullable UIViewController *)activityViewController { return nil; }

// if no view controller, this method is called. call activityDidFinish when done. default calls [self activityDidFinish:NO]
- (void)performActivity { [self activityDidFinish:NO]; }

// state method

// activity must call this when activity is finished
- (void)activityDidFinish:(BOOL)completed {
    if (self.delegate && [self.delegate respondsToSelector:@selector(activity:didFinish:)]) {
        [self.delegate activity:self didFinish:completed];
    }
}

//

@end
