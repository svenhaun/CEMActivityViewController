//
//  CEMMessageActivity.m
//  AirMonitor
//
//  Created by Sven on 3/7/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMMessageActivity.h"
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>


@interface CEMMessageActivity () <MFMessageComposeViewControllerDelegate>
//@property (nonatomic, copy) NSString* subject;
@property (nonatomic, copy) NSArray<NSData *> *imageAttaches;
@property (nonatomic, copy) NSArray<NSURL *> *urlsAttaches;
@end

@implementation CEMMessageActivity

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    _imageAttachCompressScale = 0.5f;
    return self;
}

+ (CEMActivityCategory)activityCategory {
    return CEMActivityCategoryShare;
}

- (NSString *)activityTitle {
    return @"信息";
}

- (NSString *)activityType {
    return CEMActivityTypeMessage;
}

- (UIImage *)activityImage {
    NSBundle* sourceBundle = [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:@"Resource" ofType:@"bundle"]];
    NSString* file = [sourceBundle pathForResource:@"img_ss_message@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:file];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    BOOL canPerform = NO;
    for (NSObject* object in activityItems) {
        if ([object.class isSubclassOfClass:NSString.class]) {
            canPerform = (canPerform || [MFMessageComposeViewController canSendText]);
        }
        else {
            canPerform = (canPerform || [MFMessageComposeViewController canSendAttachments]);
        }
    }

    return canPerform;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    NSMutableArray* urlsArr = [NSMutableArray array];
    NSMutableArray* imagesArr = [NSMutableArray array];
    
    for (NSObject* object in activityItems) {
        if ([object.class isSubclassOfClass:NSString.class]) {
            if (self.subject) continue;
            self.subject = (NSString *)object;
        }
        else if ([object.class isSubclassOfClass:NSURL.class]) {
            [urlsArr addObject:object];
        }
        else if ([object.class isSubclassOfClass:UIImage.class]) {
            NSData* imageData = UIImageJPEGRepresentation((UIImage *)object, _imageAttachCompressScale);
            if (!imageData) continue;
            [imagesArr addObject:imageData];
        }
    }
    
    self.urlsAttaches = urlsArr;
    self.imageAttaches = imagesArr;
}

- (UIViewController *)activityViewController {
    MFMessageComposeViewController* messageCVC = [[MFMessageComposeViewController alloc] init];
    messageCVC.messageComposeDelegate = self;
    messageCVC.subject = self.subject;
    for (NSURL* url in self.urlsAttaches) {
        [messageCVC addAttachmentURL:url withAlternateFilename:nil];
    }
    
    for (NSData* image in self.imageAttaches) {
        [messageCVC addAttachmentData:image typeIdentifier:(NSString *)kUTTypeJPEG filename:@"image"];
    }
    
    messageCVC.body = self.body ?: self.subject;
    return messageCVC;
}

#pragma mark __MFMessageComposeViewControllerDelegate_
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [controller dismissViewControllerAnimated:YES completion:NULL];
    [self activityDidFinish:(result==MessageComposeResultSent)];
}

@end



////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////         Email            ////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

@interface CEMMailActivity () <MFMailComposeViewControllerDelegate>
@property (nonatomic, copy) NSArray<NSData *> *imageAttaches;
@property (nonatomic, copy) NSArray<NSURL *> *urlsAttaches;
@end


@implementation CEMMailActivity

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    _imageAttachCompressScale = 0.5f;
    return self;
}

+ (CEMActivityCategory)activityCategory {
    return CEMActivityCategoryShare;
}

- (NSString *)activityTitle {
    return @"邮件";
}

- (NSString *)activityType {
    return CEMActivityTypeMail;
}

- (UIImage *)activityImage {
    NSBundle* sourceBundle = [NSBundle bundleWithPath:[NSBundle.mainBundle pathForResource:@"Resource" ofType:@"bundle"]];
    NSString* file = [sourceBundle pathForResource:@"img_ss_email@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:file];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return [MFMailComposeViewController canSendMail];
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    NSMutableArray* urlsArr = [NSMutableArray array];
    NSMutableArray* imagesArr = [NSMutableArray array];
    
    for (NSObject* object in activityItems) {
        if ([object.class isSubclassOfClass:NSString.class]) {
            if (self.subject) continue;
            self.subject = (NSString *)object;
        }
        else if ([object.class isSubclassOfClass:NSURL.class]) {
            [urlsArr addObject:object];
        }
        else if ([object.class isSubclassOfClass:UIImage.class]) {
            NSData* imageData = UIImageJPEGRepresentation((UIImage *)object, _imageAttachCompressScale);
            if (!imageData) continue;
            [imagesArr addObject:imageData];
        }
    }
    
    self.urlsAttaches = urlsArr;
    self.imageAttaches = imagesArr;
}

- (UIViewController *)activityViewController {
    MFMailComposeViewController* mailCVC = [[MFMailComposeViewController alloc] init];
    mailCVC.mailComposeDelegate = self;
    mailCVC.subject = self.subject;
    NSMutableString* mutBody = [NSMutableString stringWithCapacity:0];
    for (NSURL* url in self.urlsAttaches) {
        [mutBody appendFormat:@"%@\n", url];
    }
    
    int index = 0;
    for (NSData* image in self.imageAttaches) {
        [mailCVC addAttachmentData:image mimeType:@"image/jpeg"
                          fileName:[NSString stringWithFormat:@"image%d", ++index]];
    }
    
    if (self.body.length || mutBody.length) {
        [mailCVC setMessageBody:self.body ?: mutBody isHTML:NO];
    }

    return mailCVC;
}

#pragma mark __MFMessageComposeViewControllerDelegate_
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result
                        error:(nullable NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:NULL];
    [self activityDidFinish:(result==MFMailComposeResultSent)];
}


@end
