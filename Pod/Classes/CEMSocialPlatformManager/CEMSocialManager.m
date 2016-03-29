//
//  CEMSocialManager.m
//  BabyBao
//
//  Created by Sven on 10/17/14.
//  Copyright (c) 2014 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMSocialManager.h"

#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentMessageObject.h>
#import <TencentOpenAPI/TencentOAuthObject.h>

#import "WXApi.h"
#import "WeiboSDK.h"

#import "CEMSocialConfigure.h"
#import "CEMUtilities.h"

// sina weibo
NSString *const CEMSocialSinaWeibo_URLSchemeSettingKey              = @"com.cem.social_WeiboURLScheme";
NSString *const CEMSocialSinaWeibo_AppKeySettingKey                 = @"com.cem.social_WeiboAppKey";

// qq
NSString *const CEMSocialTencentQQ_AppKeySettingKey                 = @"com.cem.social_QQAppKey";
NSString *const CEMSocialTencentQQ_AppSecretSettingKey              = @"com.cem.social_QQAppSecret";

// weixin
NSString *const CEMSocialTencentWeixin_AppKeySettingKey             = @"com.cem.social_WXAppKey";
NSString *const CEMSocialTencentWeixin_AppSecretSettingKey          = @"com.cem.social_WXAppSecret";

///
#ifndef GET_APP_NAME
#define GET_APP_NAME            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
#endif

//#import
//return status
#define kSendWeiboCompletionBlockKey    @"weibo.completion.block"
#define kSendWechatCompletionBlockKey   @"wechat.completion.block"
#define kSendQQCompletionBlockKey       @"qq.completion.block"


///

static NSString * const CEMSocialNotificationQQLoginSuccessKey  = @"qq_login_suc";

// tag
static NSString * const CEMSocialHTTPTagGetUserInfo = @"get_user_info";
static NSString * const CEMSocialHTTPTagSendWeibo   = @"send_weibo";

// configure
static NSDictionary* __globalSocialConfigSettings = nil;

///
@interface CEMSocialManager ()
< WXApiDelegate,
WeiboSDKDelegate, WBHttpRequestDelegate,
TencentSessionDelegate,
QQApiInterfaceDelegate
>

@property (nonatomic, retain) NSDictionary* authResultDic;
@property (nonatomic, retain) TencentOAuth* qqOAuth;

@property (nonatomic, copy) void (^loginCompletion)(CEMSocialErrCode, NSDictionary *);

@property (nonatomic, retain) NSMutableDictionary* shareCompletionBlockDic;

- (void)installWeibo;
- (void)installWeChat;
- (void)installQQ;

- (void)getWeiboUserInfomationWithAuthDic:(NSDictionary *)authDic;

- (void)getWechatAccessTokenWithCode:(NSString *)code callback:(void (^)(NSDictionary *tokenDic, NSError* err))callback;
@end

@implementation CEMSocialManager

+ (void)InitSocialManagerWithSocialConfigureSettings:(NSDictionary *)settings {
    __globalSocialConfigSettings = settings;
    
    [CEMSocialManager sharedSocialManager];
}

+ (instancetype)sharedSocialManager {
    static CEMSocialManager* __manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __manager = [[CEMSocialManager alloc] init];
    });
    
    return __manager;
}

+ (BOOL)winxinInstalled {
    return [WXApi isWXAppInstalled];
}

+ (BOOL)weiboInstalled {
    return [WeiboSDK isWeiboAppInstalled];
}

+ (BOOL)openURL:(NSURL *)url soureApp:(NSString *)bundleId annotation:(id)annotation {

    if([TencentOAuth CanHandleOpenURL:url]){
        
        return [TencentOAuth HandleOpenURL:url];
    }
    
    if([url.scheme isEqualToString:__globalSocialConfigSettings[CEMSocialTencentQQ_AppKeySettingKey]]){
        return [WXApi handleOpenURL:url delegate:self.sharedSocialManager];
    }
    else if ([url.scheme isEqualToString:__globalSocialConfigSettings[CEMSocialSinaWeibo_URLSchemeSettingKey]]) {
        return [WeiboSDK handleOpenURL:url delegate:self.sharedSocialManager];
    }
    
    return [QQApiInterface handleOpenURL:url delegate:self.sharedSocialManager];
}

+ (void)logoutQQ {
    CEMSocialManager* socialManager = [CEMSocialManager sharedSocialManager];
    if (socialManager.qqOAuth && socialManager.qqOAuth.isSessionValid) {
        [socialManager.qqOAuth logout:NULL];
    }
    
    socialManager.qqOAuth = nil;
}

- (instancetype)init {
    if (self=[super init]) {
        [self installQQ];
        [self installWeibo];
        [self installWeChat];
        
        self.shareCompletionBlockDic = [NSMutableDictionary dictionaryWithCapacity:3];
    }
    return self;
}

#pragma mark __PRI__
// weibo
- (void)installWeibo {
    [WeiboSDK enableDebugMode:YES];
    if ([WeiboSDK registerApp:__globalSocialConfigSettings[CEMSocialSinaWeibo_AppKeySettingKey]]) {
        NSLog(@"WeiboSDK install Successful!");
    }
}

//微信
- (void)installWeChat {

    if ([WXApi registerApp:__globalSocialConfigSettings[CEMSocialTencentWeixin_AppKeySettingKey]
           withDescription:NSLocalizedString(@"appname", @"")]) {
        NSLog(@"微信初始化成功!");
    }
}

- (void)installQQ {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(qqLoginSuccess:)
                                                 name:CEMSocialNotificationQQLoginSuccessKey
                                               object:nil];
}

- (void)getWeiboUserInfomationWithAuthDic:(NSDictionary *)authDic {
    if (!authDic || !authDic.count) {
        return;
    }
    
    NSString* accessToken = authDic[@"thirdpart_token"];
    NSString* uid = authDic[@"thirdpart_id"];
    
    [WBHttpRequest requestWithAccessToken:accessToken
                                      url:@"https://api.weibo.com/2/users/show.json"
                               httpMethod:@"GET"
                                   params:@{@"uid": uid}
                                 delegate:self
                                  withTag:CEMSocialHTTPTagGetUserInfo];
}

- (void)qqLoginSuccess:(id)sender
{
    TencentOAuth* qqOAuth = self.qqOAuth; //self.authResultDic[BBKey_Thirdpart_QQ];
    BOOL suc = [qqOAuth getUserInfo];
    if (!suc) {
        
        if (self.loginCompletion) {
            self.loginCompletion(CEMSocialErrCodeFail, @{@"error": @"QQ获取用户信息失败!"});
        }
        
        return;
    }
    
    NSString* accessToken=[qqOAuth accessToken];
    NSDate* expiredDate = [qqOAuth expirationDate];
    NSString* userId = [qqOAuth openId];
    self.authResultDic = @{@"thirdpart_token": accessToken,
                           @"thirdpart_expire_date":[expiredDate cem_stringWithFormat:@"yyyy/MM/dd HH:mm:ss"],
                           @"thirdpart_id": userId };
}

#pragma mark __PUB__
- (void)loginWeiboWithCompletion:(void (^)(CEMSocialErrCode, NSDictionary *))completion {
    self.loginCompletion = completion;
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = @"http://www.cem-instruments.com";
    request.scope = @"all";
    
    [WeiboSDK sendRequest:request];
}

- (void)loginQQWithCompletion:(void (^)(CEMSocialErrCode, NSDictionary *))completion {
    self.loginCompletion = completion;
    if (self.qqOAuth && self.qqOAuth.isSessionValid) {
        [self qqLoginSuccess:nil];
        if (completion) {
            completion(CEMSocialErrCodeSucceed, self.authResultDic);
        }
        return;
    }
    
    if (!self.qqOAuth) {
        TencentOAuth* qqOauth = [[TencentOAuth alloc]initWithAppId:__globalSocialConfigSettings[CEMSocialTencentQQ_AppKeySettingKey]
                                                       andDelegate:self];
//        qqOauth.redirectURI = TENCENT_QQ_REDIRECTURI;
//        qqOauth.redirectURI = @"sns.whalecloud.com";

        self.qqOAuth = qqOauth;
    }
    
    NSArray *permissions = @[kOPEN_PERMISSION_GET_INFO,
                             kOPEN_PERMISSION_GET_USER_INFO,
                             kOPEN_PERMISSION_GET_SIMPLE_USER_INFO];
    
    if ([self.qqOAuth authorize:permissions]) {
        NSLog(@"");
    }
}

- (void)loginQQZoneWithCompletion:(void (^)(CEMSocialErrCode, NSDictionary *))completion {
    self.loginCompletion = completion;
}

- (void)loginWeChatWithCompletion:(void (^)(CEMSocialErrCode, NSDictionary *))completion {
    self.loginCompletion = completion;
    
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = @"com.cem.AQI" ;
    [WXApi sendReq:req];
}

- (BOOL)canSendToWeChat:(NSString *__autoreleasing *)wechatAppStoreURL {
    if ([WXApi isWXAppInstalled]) {
        return YES;
    }
    else if (wechatAppStoreURL) {
        *wechatAppStoreURL = [WXApi getWXAppInstallUrl];
    }
    
    return NO;
}

- (BOOL)canSendToWeiboClient:(NSString *__autoreleasing *)weiboAppStoreURL {
    if ([WeiboSDK isWeiboAppInstalled]) return YES;

    if (weiboAppStoreURL) {
        *weiboAppStoreURL = [WeiboSDK getWeiboAppInstallUrl];
    }
    
    return NO;
}

- (void)sendToWeiboClientWithMedia:(UIImage *)image text:(NSString *)text {
    if (!image && !text) return;
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = text;
    if (image) {
        WBImageObject *imageO = [WBImageObject object];
        imageO.imageData = UIImagePNGRepresentation(image);
        message.imageObject = imageO;
    }
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    request.shouldOpenWeiboAppInstallPageIfNotInstalled = YES;
    
    if (![WeiboSDK sendRequest:request]) {
        NSLog(@"Weibo Send Failed!\n");
    }
}

- (void)sendMediaToWeibo:(NSString *)token image:(UIImage *)image text:(NSString *)text
              completion:(void (^)(CEMSocialErrCode))completion {

    if (completion) {
        [self.shareCompletionBlockDic setObject:completion forKey:kSendWeiboCompletionBlockKey];
    }
    
    if (!token || (!image && !text)) {
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:2];
    if (text) {
        [dic setObject:text forKey:@"status"];
    }
    
    if (image) {
        [dic setObject:image forKey:@"pic"];
    }
    
    [WBHttpRequest requestWithAccessToken:token
                                      url:@"https://api.weibo.com/2/statuses/upload.json"
                               httpMethod:@"POST"
                                   params:dic
                                 delegate:self
                                  withTag:CEMSocialHTTPTagSendWeibo];
}

- (void)sendToWeiboClientWithMedia:(NSString *)sourceURL
                             title:(NSString *)title description:(NSString *)description
                           preview:(UIImage *)preview {
    [self sendToWeiboClientWithMedia:sourceURL title:title description:description preview:preview completion:NULL];
}

- (void)sendToWeiboClientWithMedia:(NSString *)sourceURL
                             title:(NSString *)title description:(NSString *)description
                           preview:(UIImage *)preview
                        completion:(void (^)(CEMSocialErrCode))completion {
    void (^finish)(CEMSocialErrCode) = ^(CEMSocialErrCode code) {
        if (completion) completion(code);
    };
    
    if (!sourceURL) {
        finish(CEMSocialErrCodeFail);
        return;
    }
    
    WBMessageObject *message = [WBMessageObject message];
    message.text = description;
    NSData* previewData;
    if (preview && [preview isKindOfClass:UIImage.class]) {
        previewData = UIImagePNGRepresentation(preview);
    }
    
    WBWebpageObject* webpageO = [WBWebpageObject object];
    webpageO.objectID = [NSDate.date cem_stringWithFormat:@"yyyy-MM-dd HH:mm:ss"];
    webpageO.webpageUrl = sourceURL;
    webpageO.title = title;
    webpageO.description = description;
    
    message.mediaObject = webpageO;
    
    if (previewData) {
        webpageO.thumbnailData = previewData;
    }
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    request.shouldOpenWeiboAppInstallPageIfNotInstalled = YES;
    if (![WeiboSDK sendRequest:request]) {
        NSLog(@"Weibo Send Failed!\n");
        finish(CEMSocialErrCodeFail);
        return;
    }
    
    if (completion) {
        [self.shareCompletionBlockDic setObject:completion forKey:kSendWeiboCompletionBlockKey];
    }
}

- (void)sendToTencentSession:(CEMSocialPlatformTencentSession)tencentSession withText:(NSString *)text {
    if (!text) return;
    
    if (tencentSession == CEMSocialPlatformTencentQQSession) {
        [self loginQQWithCompletion:^(CEMSocialErrCode code, NSDictionary *infoDic) {
            if (code == CEMSocialErrCodeSucceed) {
                QQApiTextObject *txtObj = [QQApiTextObject objectWithText:text];
                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:txtObj];
                //将内容分享到qq
                QQApiSendResultCode sent = [QQApiInterface sendReq:req];
                if (sent != EQQAPISENDSUCESS) {
                    NSLog(@"send failed: %d", sent);
                }
            }
        }];
    }
    else if (tencentSession == CEMSocialPlatformTencentWeChatSession) {
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.text = text;
        req.bText = YES;
        req.scene= WXSceneSession;
        
        if(![WXApi sendReq:req]){
            NSLog(@"Send WeChat failed!");
        }
    }
}

- (void)sendToTencentSession:(CEMSocialPlatformTencentSession)tencentSession withImage :(UIImage *)image {
    if (!image) return;

    NSData *imgData = UIImagePNGRepresentation(image);
    NSData *preview = UIImageJPEGRepresentation(image, 0.1);
    
    if (tencentSession == CEMSocialPlatformTencentQQSession) {
        [self loginQQWithCompletion:^(CEMSocialErrCode code, NSDictionary *infoDic) {
            if (code == CEMSocialErrCodeSucceed) {
                QQApiImageObject *imgObj = [QQApiImageObject objectWithData:imgData
                                                           previewImageData:preview
                                                                      title:GET_APP_NAME
                                                                description:[NSString stringWithFormat:@"来自%@的分享", GET_APP_NAME]];
                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
                //将内容分享到qq
                QQApiSendResultCode sent = [QQApiInterface sendReq:req];
//                QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
                if (sent != EQQAPISENDSUCESS) {
                    NSLog(@"send failed: %d", sent);
                }
            }
        }];
    }
    else if (tencentSession == CEMSocialPlatformTencentWeChatSession) {
        
        WXImageObject* imageO = [WXImageObject object];
        imageO.imageData = imgData;
        
        WXMediaMessage* media = [WXMediaMessage message];
                
        media.title = GET_APP_NAME;
        media.mediaObject = imageO;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.message = media;
        req.bText = NO;
        req.scene= WXSceneSession;
        
        if(![WXApi sendReq:req]){
            NSLog(@"Send WeChat failed!");
        }
    }
}

- (void)sendToTencentSession:(CEMSocialPlatformTencentSession)tencentSession withFile:(NSData *)file extension:(NSString *)ext {
    if (!file || !ext) return;
    if (tencentSession == CEMSocialPlatformTencentQQSession) {
//        [self loginQQWithCompletion:^(CEMSocialErrCode code, NSDictionary *infoDic) {
//            if (code == CEMSocialErrCodeSucceed) {
//                QQApiFileObject *fileObj = [QQApiFileObject objectWithData:file
//                                                          previewImageData:UIImageJPEGRepresentation([UIImage imageNamed:@"first"], 1)
//                                                                     title:@"分享"
//                                                               description:@"share"];
//                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:fileObj];
//                //将内容分享到qq
//                QQApiSendResultCode sent = [QQApiInterface sendReq:req];
//                if (sent != EQQAPISENDSUCESS) {
//                    NSLog(@"send failed: %d", sent);
//                }
//            }
//        }];
    }
    else if (tencentSession == CEMSocialPlatformTencentWeChatSession) {
        WXFileObject* fileO = [WXFileObject object];
        fileO.fileData = file;
        fileO.fileExtension = ext;
        
        WXMediaMessage* media = [WXMediaMessage message];
        
        media.title = GET_APP_NAME;
        media.mediaObject = fileO;
//        media.description = [NSString stringWithFormat:@"laoi %@ shareD", GET_APP_NAME];
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.message = media;
        req.bText = NO;
        req.scene= WXSceneSession;
        
        if(![WXApi sendReq:req]){
            NSLog(@"Send WeChat failed!");
        }
    }
}

- (void)sendToTencentSession:(CEMSocialPlatformTencentSession)tencentSession
                   sourceURL:(NSString *)sourceURL title:(NSString *)title
                 description:(NSString *)description preview:(UIImage *)preview {
    [self sendToTencentSession:tencentSession sourceURL:sourceURL
                         title:title description:description preview:preview
                    completion:NULL];
}

- (void)sendToTencentSession:(CEMSocialPlatformTencentSession)tencentSession
                   sourceURL:(NSString *)sourceURL
                       title:(NSString *)title description:(NSString *)description preview:(UIImage *)preview
                  completion:(void (^)(CEMSocialErrCode))completion {
    
    if (!sourceURL) {
        NSLog(@"nothing to share!");
        return;
    }
    
    void (^finish)(CEMSocialErrCode) = ^(CEMSocialErrCode code) {
        if (completion) completion(code);
    };

    //
    NSData* imageData;
    if (preview) {
        imageData = UIImageJPEGRepresentation(preview, .5);
    }
    
    if (!title && !description) title = GET_APP_NAME;
    
    if (tencentSession == CEMSocialPlatformTencentQQSession) {
        
        __weak __typeof__(self) weakSelf = self;
        
        [self loginQQWithCompletion:^(CEMSocialErrCode code, NSDictionary *infoDic) {
            
            if (code == CEMSocialErrCodeSucceed) {
                
                QQApiNewsObject *object = [QQApiNewsObject
                                            objectWithURL:[NSURL URLWithString:sourceURL]
                                            title:title
                                            description:description
                                            previewImageData:imageData];
                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:object];
                //将内容分享到qq
                QQApiSendResultCode sent = [QQApiInterface sendReq:req];
                if (sent != EQQAPISENDSUCESS) {
                    NSLog(@"send failed: %d", sent);
                    finish(CEMSocialErrCodeFail);
                    return;
                }
                
                if (completion) {
                    [weakSelf.shareCompletionBlockDic setObject:completion forKey:kSendQQCompletionBlockKey];
                }
            }
            else {
                NSLog(@"err :%@", infoDic);
                finish(code);
            }
        }];
    }
    else if (tencentSession == CEMSocialPlatformTencentWeChatSession) {
        
        WXWebpageObject* wbObject = [WXWebpageObject object];
        wbObject.webpageUrl = sourceURL;
        
        WXMediaMessage* media = [WXMediaMessage message];
        media.title = title;
        media.description = description;
        media.thumbData = imageData;
        media.mediaObject = wbObject;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.scene= WXSceneSession;
        req.message = media;
        
        if(![WXApi sendReq:req]){
            NSLog(@"Send WeChat failed!");
            finish(CEMSocialErrCodeFail);
            return;
        }
        
        if (completion) {
            [self.shareCompletionBlockDic setObject:completion forKey:kSendWechatCompletionBlockKey];
        }
    }

}

- (void)sendToTencentTimeline:(CEMSocialPlatformTencentTimeline)tencentTimeline
                    sourceURL:(NSString *)sourceURL
                        title:(NSString *)title description:(NSString *)description
                      preview:(UIImage *)preview
{
    [self sendToTencentTimeline:tencentTimeline sourceURL:sourceURL
                          title:title description:description preview:preview
                     completion:NULL];
}

- (void)sendToTencentTimeline:(CEMSocialPlatformTencentTimeline)tencentTimeline
                    sourceURL:(NSString *)sourceURL title:(NSString *)title description:(NSString *)description preview:(UIImage *)preview
                   completion:(void (^)(CEMSocialErrCode))completion {

    if (!sourceURL && !title && !description) {
        NSLog(@"nothing to share!");
        return;
    }
    
    void (^finish)(CEMSocialErrCode) = ^(CEMSocialErrCode code) {
        if (completion) {
            completion(code);
        }
    };
    
    
    NSData* imageData;
    if (preview) imageData = UIImageJPEGRepresentation(preview, 0.1);
    
    if (!title && !description) title = GET_APP_NAME;
    
    if (tencentTimeline == CEMSocialPlatformTencentQQZoneTimeline) {
        __weak __typeof__(self) weakSelf = self;
        
        [self loginQQWithCompletion:^(CEMSocialErrCode code, NSDictionary *infoDic) {
            if (code == CEMSocialErrCodeSucceed) {
                
                QQApiNewsObject *newsObj = [QQApiNewsObject
                                            objectWithURL:[NSURL URLWithString:sourceURL]
                                            title:title
                                            description:description
                                            previewImageData:imageData];
                SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
                
                //将内容分享到qzone
                QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
                if (sent != EQQAPISENDSUCESS) {
                    NSLog(@"send failed: %d", sent);
                    finish(CEMSocialErrCodeFail);
                    return;
                }
                
                if (completion) {
                    [weakSelf.shareCompletionBlockDic setObject:completion forKey:kSendQQCompletionBlockKey];
                }
            }
            else {
                NSLog(@"err :%@", infoDic);
                finish(CEMSocialErrCodeFail);
            }
        }];
    }
    else if (tencentTimeline == CEMSocialPlatformTencentWeChatTimeline) {
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = sourceURL;
        
        WXMediaMessage *message = [WXMediaMessage message];
        message.title = title;
        message.description = description;
        [message setThumbImage:preview];
        message.mediaObject = ext;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.message = message;
        req.bText = NO;
        req.scene= WXSceneTimeline;
        
        if(![WXApi sendReq:req]){
            NSLog(@"Send WeChat failed!");
            finish(CEMSocialErrCodeFail);
            return;
        }
        
        if (completion) {
            [self.shareCompletionBlockDic setObject:completion forKey:kSendWechatCompletionBlockKey];
        }

    }

}

- (void)sendToWechatTimelineWithSource:(UIImage *)image title:(NSString *)title description:(NSString *)description {
    NSData* imageData = UIImageJPEGRepresentation(image, 1.f);
    NSData* previewImageData = UIImageJPEGRepresentation(image, 0.1);
    
    BOOL isText = imageData == nil;
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    if (isText) {
        req.bText = YES;
        req.text = description ?: title;
    }
    else {
        WXImageObject* imgObject = [WXImageObject object];
        imgObject.imageData = imageData;
        
        WXMediaMessage* media = [WXMediaMessage message];
        media.title = title;
        media.description = description;
        media.thumbData = previewImageData;
        media.mediaObject =  isText ? nil : imgObject;
        
        req.message = media;
        req.bText = NO;
    }
    
    req.scene= WXSceneTimeline;
    
    if(![WXApi sendReq:req]){
        NSLog(@"Send WeChat failed!");
    }
}

- (void)sendToQQzoneWithSource:(UIImage *)image
                         title:(NSString *)title
                   description:(NSString *)description {
    if (!title && !description && !image) return;
    
    [self loginQQWithCompletion:^(CEMSocialErrCode code, NSDictionary *infoDic) {
        if (code == CEMSocialErrCodeSucceed) {
            QQApiObject* object;
            if (image) {
                NSData* imageData = UIImageJPEGRepresentation(image, 1.f);
                NSData* previewData = UIImageJPEGRepresentation(image, 0.1);
                object = [QQApiImageObject objectWithData:imageData previewImageData:previewData
                                                    title:title description:description];
            }
            else {
                object = [QQApiTextObject
                          objectWithText:description ?: title];
            }
  
//            textObj.title = description;
            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:object];
            QQApiSendResultCode sent = [QQApiInterface SendReqToQZone:req];
            
            if (sent != EQQAPISENDSUCESS) {
                NSLog(@"send failed: %d", sent);
                return;
            }
        }
    }];
}

#pragma mark __WeiboSDK__
- (void)didReceiveWeiboRequest:(WBBaseRequest *)request{
    
    NSLog(@"req :%@", request);
    if ([request isKindOfClass:WBProvideMessageForWeiboRequest.class]) {
        NSLog(@"ABCD:");
    }
}

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response{
    
    if([response statusCode] == WeiboSDKResponseStatusCodeSuccess) {
        
        if([response isKindOfClass:WBAuthorizeResponse.class]) {    // login
            
            //认证成功  登录
            NSString *strAccessToken=[(WBAuthorizeResponse*)response accessToken];
            NSDate *exDate=[(WBAuthorizeResponse*)response expirationDate];
            NSString *uid=[(WBAuthorizeResponse*)response userID];
            NSString* strExDate = [exDate cem_stringWithFormat:@"yyyy/MM/dd HH:mm:ss"];
            self.authResultDic = @{@"thirdpart_token": strAccessToken, @"thirdpart_expire_date": strExDate,
                                   @"thirdpart_id": uid};
            NSLog(@"auth :%@", self.authResultDic);

            //取用户信息
            [self getWeiboUserInfomationWithAuthDic:self.authResultDic];
            
        }
        else if([response isKindOfClass:WBSendMessageToWeiboResponse.class]){
            
            NSLog(@"Send Weibo Seccess!");
            //微博客户端发送成功
            CEMSocialSendMediaBlock completion = self.shareCompletionBlockDic[kSendWeiboCompletionBlockKey];
            if (completion) {
                completion(CEMSocialErrCodeSucceed);
            }
            
            [self.shareCompletionBlockDic removeObjectForKey:kSendWeiboCompletionBlockKey];
        }
    }
    else if (response.statusCode != WeiboSDKResponseStatusCodeUserCancel) {
        
        if ([response isKindOfClass:WBAuthorizeResponse.class]) {
            // user cancel
            
            if (self.loginCompletion) {
                self.loginCompletion(CEMSocialErrCodeFail, response.requestUserInfo);
            }
        }
    }
    else {
        
        if ([response isKindOfClass:WBAuthorizeResponse.class]) {
            // user cancel
            
            if (self.loginCompletion) {
                self.loginCompletion(CEMSocialErrCodeLoginCancel, nil);
            }
        }
        else if ([response isKindOfClass:WBSendMessageToWeiboResponse.class]) {
            NSLog(@"Send Weibo Failed!");
            
            CEMSocialSendMediaBlock completion = self.shareCompletionBlockDic[kSendWeiboCompletionBlockKey];
            if (completion) {
                completion(CEMSocialErrCodeFail);
            }
            
            [self.shareCompletionBlockDic removeObjectForKey:kSendWeiboCompletionBlockKey];
        }
    }
}

#pragma mark __WBHttpRequestDelegate__
- (void)request:(WBHttpRequest *)request didReceiveResponse:(NSURLResponse *)response {}

- (void)request:(WBHttpRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"err :%@", error);
    if (request.tag == CEMSocialHTTPTagGetUserInfo) {
        if (self.loginCompletion) {
            NSDictionary* infoDic;
            if (error) {
                infoDic = @{@"error": error};
            }
            
            self.loginCompletion(CEMSocialErrCodeFail, infoDic);
        }
    }
    else if (request.tag == CEMSocialHTTPTagSendWeibo) {
        CEMSocialSendMediaBlock completion = self.shareCompletionBlockDic[kSendWeiboCompletionBlockKey];
        if (completion) {
            completion(error ? CEMSocialErrCodeFail : CEMSocialErrCodeSucceed);
        }
        
        [self.shareCompletionBlockDic removeObjectForKey:kSendWeiboCompletionBlockKey];
    }
}

- (void)request:(WBHttpRequest *)request didFinishLoadingWithDataResult:(NSData *)data
{
    NSError* err;
    NSDictionary* resDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments
                                                             error:&err];
    
    NSLog(@"res :%@", resDic);
    if (!resDic) {
        return;
    }
    
    BOOL error = ([resDic objectForKey:@"error"] == nil) ? NO : YES;

    if([request.tag isEqualToString:CEMSocialHTTPTagGetUserInfo]) {
    
        if (!error) {
            NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:self.authResultDic];
            [dic setObject:resDic[@"screen_name"] forKey:@"nickname"];
            
            [dic setObject:resDic[@"avatar_large"/*@"profile_image_url"*/] forKey:@"icon"];
            [dic setObject:@([resDic[@"gender"] isEqualToString:@"m"] ? 1 : 0) forKey:@"sex"];
            
            if (self.loginCompletion) {
                self.loginCompletion(CEMSocialErrCodeSucceed, dic);
            }
        }
        else {
            if (self.loginCompletion) {
                self.loginCompletion(CEMSocialErrCodeFail, @{@"error": resDic[@"error"]});
            }
        }
    }
    else if ([request.tag isEqualToString:CEMSocialHTTPTagSendWeibo]) {
        
        CEMSocialSendMediaBlock completion = self.shareCompletionBlockDic[kSendWeiboCompletionBlockKey];
        if (completion) {
            completion(error ? CEMSocialErrCodeFail : CEMSocialErrCodeSucceed);
        }
        
        [self.shareCompletionBlockDic removeObjectForKey:kSendWeiboCompletionBlockKey];
    }
}

/**************************************************************************************************************/
#pragma mark __TencentSessionDelegate__

- (void)tencentDidNotLogin:(BOOL)cancelled{
    
//    self.qqOAuth = nil;
    
    if (self.loginCompletion) {
        if (cancelled) {
            self.loginCompletion(CEMSocialErrCodeLoginCancel, nil);
        }
        else {
            self.loginCompletion(CEMSocialErrCodeFail, @{@"error": @"QQ登录失败"});
        }
    }
}

- (void)tencentDidNotNetWork { }

- (void)tencentDidLogin {
    [[NSNotificationCenter defaultCenter] postNotificationName:CEMSocialNotificationQQLoginSuccessKey object:nil];
}

- (void)tencentDidLogout {}

- (NSArray *)getAuthorizedPermissions:(NSArray *)permissions withExtraParams:(NSDictionary *)extraParams {
    NSLog(@"\npermissions: %@\nextraparams: %@", permissions, extraParams);
    
    return nil;
}

- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth withPermissions:(NSArray *)permissions { return YES; }
- (BOOL)tencentNeedPerformReAuth:(TencentOAuth *)tencentOAuth { return YES; }
- (BOOL)onTencentReq:(TencentApiReq *)req { return YES; }
- (BOOL)onTencentResp:(TencentApiResp *)resp { return YES; }

//获取个人信息回调
- (void)getUserInfoResponse:(APIResponse *)response{
    
    NSDictionary *resDic=[response jsonResponse];
    NSLog(@"res :%@", resDic);
    
    if(response.retCode == 0){
        
        NSString *nickname=[resDic objectForKey:@"nickname"];
        NSString *headimag=[resDic objectForKey:@"figureurl_qq_2"];
        NSString* headimagsmall = resDic[@"figureurl_qq_1"];
        
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:self.authResultDic];
        [dic setObject:nickname forKey:@"nickname"];
        
        [dic setObject:headimag forKey:@"icon"];
        [dic setObject:headimagsmall forKey:@"icon_small"];
        
        if (self.loginCompletion) {
            self.loginCompletion(CEMSocialErrCodeSucceed, dic);
        }
    }
    else {
        if (self.loginCompletion) {
            self.loginCompletion(CEMSocialErrCodeFail, @{@"error": resDic[@"error"]});
        }
    }
}

#pragma mark WX__
- (void)getWechatAccessTokenWithCode:(NSString *)code callback:(void (^)(NSDictionary*, NSError *))callback {
    //https://api.weixin.qq.com/sns/oauth2/access_token?appid=APPID&secret=SECRET&code=CODE&grant_type=authorization_code
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", __globalSocialConfigSettings[CEMSocialTencentWeixin_AppKeySettingKey], __globalSocialConfigSettings[CEMSocialTencentWeixin_AppSecretSettingKey], code];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSError* error;
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:&error];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dic;
            if (data) {
                dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 "access_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWiusJMZwzQU8kXcnT1hNs_ykAFDfDEuNp6waj-bDdepEzooL_k1vb7EQzhP8plTbD0AgR8zCRi1It3eNS7yRyd5A";
                 "expires_in" = 7200;
                 openid = oyAaTjsDx7pl4Q42O3sDzDtA7gZs;
                 "refresh_token" = "OezXcEiiBSKSxW0eoylIeJDUKD6z6dmr42JANLPjNN7Kaf3e4GZ2OncrCfiKnGWi2ZzH_XfVVxZbmha9oSFnKAhFsS0iyARkXCa7zPu4MqVRdwyb8J16V8cWw7oNIff0l-5F-4-GJwD8MopmjHXKiA";
                 scope = "snsapi_userinfo,snsapi_base";
                 }
                 */
            }
            
            if (callback) {
                callback([dic mutableCopy], error);
            }
        });
    });
}

-(void)getUserInfoWithToken:(NSString *)token openId:(NSString *)openId callback:(void (^)(NSDictionary*, NSError *))callback {
    // https://api.weixin.qq.com/sns/userinfo?access_token=ACCESS_TOKEN&openid=OPENID
    
    NSString *url =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@", token, openId];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        NSError* error;
        NSURL *zoneUrl = [NSURL URLWithString:url];
        NSString *zoneStr = [NSString stringWithContentsOfURL:zoneUrl encoding:NSUTF8StringEncoding error:&error];
        NSData *data = [zoneStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *dic;
            if (data) {
                dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                /*
                 {
                 city = Haidian;
                 country = CN;
                 headimgurl = "http://wx.qlogo.cn/mmopen/FrdAUicrPIibcpGzxuD0kjfnvc2klwzQ62a1brlWq1sjNfWREia6W8Cf8kNCbErowsSUcGSIltXTqrhQgPEibYakpl5EokGMibMPU/0";
                 language = "zh_CN";
                 nickname = "xxx";
                 openid = oyAaTjsDx7pl4xxxxxxx;
                 privilege =     (
                 );
                 province = Beijing;
                 sex = 1;
                 unionid = oyAaTjsxxxxxxQ42O3xxxxxxs;
                 }
                 */
            }
            
            if (callback) {
                callback([dic mutableCopy], error);
            }
        });
        
    });
}

#pragma mark __WX__Delegate__
- (void)isOnlineResponse:(NSDictionary *)response {}

-(void) onReq:(BaseReq*)req {
    
}

-(void) onResp:(BaseResp*)resp {
    /*
     ErrCode ERR_OK = 0(用户同意)
     ERR_AUTH_DENIED = -4（用户拒绝授权）
     ERR_USER_CANCEL = -2（用户取消）
     code    用户换取access_token的code，仅在ErrCode为0时有效
     state   第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
     lang    微信客户端当前语言
     country 微信用户当前国家信息
     */
    if ([resp isKindOfClass:SendAuthResp.class]) {
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (aresp.errCode == WXSuccess) {
            NSString *code = aresp.code;
            
            [self getWechatAccessTokenWithCode:code callback:^(NSDictionary *tokenDic, NSError *err) {
                
                if (err) {
                    if (self.loginCompletion) {
                        self.loginCompletion(CEMSocialErrCodeFail, @{@"error": err.localizedDescription?:@""});
                    }
                    
                    return;
                }
                
                NSLog(@"tocken dic :%@", tokenDic);
                NSString* token = tokenDic[@"access_token"];
                NSString* openId = tokenDic[@"openid"];
                NSDate* expiredDate = [NSDate dateWithTimeIntervalSinceNow:90 * 24 * 60 * 60];
                
                self.authResultDic = @{@"thirdpart_token": token,
                                       @"thirdpart_expire_date":[expiredDate cem_stringWithFormat:@"yyyy/MM/dd HH:mm:ss"],
                                       @"thirdpart_id": openId };
                
                [self getUserInfoWithToken:token openId:openId
                                  callback:^(NSDictionary *infoDic, NSError *err) {
                    
                                      if (err) {
                                          if (self.loginCompletion) {
                                              self.loginCompletion(CEMSocialErrCodeFail, @{@"error": err.localizedDescription?:@""});
                                          }
                                          
                                          return;
                                      }
                                      
                                      NSLog(@"infoDic :%@", infoDic);
                                      /* {
                                       city = Shenzhen;
                                       country = CN;
                                       headimgurl = "http://wx.qlogo.cn/mmopen/OVNywZRyBy7R6YGWdleicPQ2qNV4rVt2PBZBlO4nxt2kXW9SYKsN8aPOKhwzlsEbFzcNwTgq2HDUoUBJM6HibkjbqPQgWswMNc/0";
                                       language = "zh_CN";
                                       nickname = Sven;
                                       openid = ofR5es0eXSh9sbdCwmgrg00ARoOw;
                                       privilege =     (
                                       );
                                       province = Guangdong;
                                       sex = 1;
                                       unionid = oW7hmuBeUc6z1AfKxt6nNecN931w;
                                       }
                                       */
        
                                      NSMutableDictionary* retDic = [NSMutableDictionary dictionaryWithDictionary:self.authResultDic];
                                      [retDic setObject:infoDic[@"nickname"] forKey:@"nickname"];
                                      [retDic setObject:@(2 - [infoDic[@"sex"] integerValue]) forKey:@"sex"];
                                      [retDic setObject:infoDic[@"headimgurl"] forKey:@"icon"];
                                      
                                      if (self.loginCompletion) {
                                          self.loginCompletion(CEMSocialErrCodeSucceed, retDic);
                                      }
                                      
                                  }];
            }];
        }
        else {
         
            CEMSocialErrCode errCode = aresp.errCode == WXErrCodeUserCancel ? CEMSocialErrCodeLoginCancel : CEMSocialErrCodeFail;
            if (self.loginCompletion) {
                self.loginCompletion(errCode, @{@"error": aresp.errStr?:@""});
            }
        }
    }
    else if ([resp isKindOfClass:SendMessageToWXResp.class]) {

        CEMSocialSendMediaBlock completion = self.shareCompletionBlockDic[kSendWechatCompletionBlockKey];
        if (!completion) return;
        
        SendMessageToWXResp* mresp = (SendMessageToWXResp *)resp;
        CEMSocialErrCode errCode = mresp.errCode == WXErrCodeUserCancel ? CEMSocialErrCodeLoginCancel : CEMSocialErrCodeFail;
        if (mresp.errCode == WXSuccess) {
            errCode = CEMSocialErrCodeSucceed;
        }
        
        completion(errCode);
        [self.shareCompletionBlockDic removeObjectForKey:kSendWechatCompletionBlockKey];
    }
    else if ([resp isKindOfClass:SendMessageToQQResp.class]) {
        CEMSocialSendMediaBlock completion = self.shareCompletionBlockDic[kSendQQCompletionBlockKey];
        if (!completion) return;

        SendMessageToQQResp* qResp = (SendMessageToQQResp *)resp;
        
        int code = [qResp.result intValue];
        CEMSocialErrCode errCode = code == -4 ? CEMSocialErrCodeLoginCancel : CEMSocialErrCodeFail;
        if (code == 0) errCode = CEMSocialErrCodeSucceed;
        
        completion(errCode);
        [self.shareCompletionBlockDic removeObjectForKey:kSendQQCompletionBlockKey];
    }
}

@end
