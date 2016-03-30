//
//  CEMSocialManager.h
//  BabyBao
//
//  Created by Sven on 10/17/14.
//  Copyright (c) 2014 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, CEMSocialErrCode) {
    CEMSocialErrCodeSucceed,
    CEMSocialErrCodeLoginCancel,
    CEMSocialErrCodeFail,
};

typedef NS_ENUM(NSInteger, CEMSocialPlatformTencentSession) {
    CEMSocialPlatformTencentQQSession,
    CEMSocialPlatformTencentWeChatSession,
};

typedef NS_ENUM(NSInteger, CEMSocialPlatformTencentTimeline) {
    CEMSocialPlatformTencentQQZoneTimeline,
    CEMSocialPlatformTencentWeChatTimeline,
};

typedef void (^CEMSocialSendMediaBlock)(CEMSocialErrCode code);

@interface CEMSocialManager : NSObject

// must call it before using social functions
/**
 *  { CEMSocialSinaWeibo_URLSchemeSettingKey: ..,
 *    CEMSocialSinaWeibo_AppKeySettingKey: ..,
 *    CEMSocialTencentQQ_AppKeySettingKey: ..,
 *    ... }
 */
+ (void)InitSocialManagerWithSocialConfigureSettings:(NSDictionary *)settings;

//
+ (BOOL)winxinInstalled;
+ (BOOL)weiboInstalled;
+ (BOOL)qqInstalled;

//
+ (instancetype)sharedSocialManager;

+ (void)logoutQQ;

+ (BOOL)openURL:(NSURL *)url soureApp:(NSString *)bundleId annotation:(id)annotation;

// login from weibo
- (void)loginWeiboWithCompletion:(void (^)(CEMSocialErrCode code, NSDictionary* infoDic))completion;

// login from qq
- (void)loginQQWithCompletion:(void (^)(CEMSocialErrCode code, NSDictionary* infoDic))completion;

// login from qqzone (not implementation)
- (void)loginQQZoneWithCompletion:(void (^)(CEMSocialErrCode code, NSDictionary* infoDic))completion;

// login from wechat (not implementaion)
- (void)loginWeChatWithCompletion:(void (^)(CEMSocialErrCode code, NSDictionary* infoDic))completion;

// send text or media info
/************** Weibo ************************************/
- (BOOL)canSendToWeiboClient:(NSString **)weiboAppStoreURL;
- (void)sendToWeiboClientWithMedia:(UIImage *)image text:(NSString *)text;
- (void)sendMediaToWeibo:(NSString *)token image:(UIImage *)image text:(NSString *)text
              completion:(void (^)(CEMSocialErrCode code))completion;
- (void)sendToWeiboClientWithMedia:(NSString *)sourceURL
                             title:(NSString *)title description:(NSString *)description
                           preview:(UIImage *)preview;
- (void)sendToWeiboClientWithMedia:(NSString *)sourceURL
                             title:(NSString *)title description:(NSString *)description
                           preview:(UIImage *)preview
                        completion:(void (^)(CEMSocialErrCode code))completion;

/************** Tencent **********************************/
- (BOOL)canSendToWeChat:(NSString **)wechatAppStoreURL;

- (void)sendToTencentSession:(CEMSocialPlatformTencentSession)tencentSession withText:(NSString *)text;
- (void)sendToTencentSession:(CEMSocialPlatformTencentSession)tencentSession withImage:(UIImage *)image;
- (void)sendToTencentSession:(CEMSocialPlatformTencentSession)tencentSession withFile:(NSData *)file extension:(NSString *)ext;

///
- (void)sendToTencentSession:(CEMSocialPlatformTencentSession)tencentSession
                   sourceURL:(NSString *)sourceURL title:(NSString *)title
                 description:(NSString *)description
                     preview:(UIImage *)preview;

- (void)sendToTencentSession:(CEMSocialPlatformTencentSession)tencentSession
                   sourceURL:(NSString *)sourceURL title:(NSString *)title
                 description:(NSString *)description
                     preview:(UIImage *)preview
                  completion:(void (^)(CEMSocialErrCode code))completion;

- (void)sendToTencentTimeline:(CEMSocialPlatformTencentTimeline)tencentTimeline
                    sourceURL:(NSString *)sourceURL title:(NSString *)title
                  description:(NSString *)description
                      preview:(UIImage *)preview;
// com.
- (void)sendToTencentTimeline:(CEMSocialPlatformTencentTimeline)tencentTimeline
                    sourceURL:(NSString *)sourceURL title:(NSString *)title
                  description:(NSString *)description
                      preview:(UIImage *)preview
                   completion:(void (^)(CEMSocialErrCode code))completion;

// wx
- (void)sendToWechatTimelineWithSource:(UIImage *)image
                                 title:(NSString *)title
                           description:(NSString *)description;

- (void)sendToQQzoneWithSource:(UIImage *)image
                         title:(NSString *)title
                   description:(NSString *)description;

@end
