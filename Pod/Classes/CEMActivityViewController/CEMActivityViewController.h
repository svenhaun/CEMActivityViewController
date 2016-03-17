//
//  CEMActivityViewController.h
//  AirMonitor
//
//  Created by Sven on 3/5/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CEMActivity.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^CEMActivityViewControllerCompletionHandler)(NSString * __nullable activityType, BOOL completed);
//typedef void (^CEMActivityViewControllerCompletionWithItemsHandler)(NSString * __nullable activityType, BOOL completed, NSArray * __nullable returnedItems, NSError * __nullable activityError);

//
NS_CLASS_AVAILABLE_IOS(7_0) @interface CEMActivityViewController : UIViewController
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithTitle:(nullable NSString *)title activityItems:(nullable NSArray *)activityItems applicationActivities:(nullable NSArray<__kindof CEMActivity *> *)applicationActivities NS_DESIGNATED_INITIALIZER;

@property(nullable, nonatomic, copy) NSArray<NSString *> *excludedActivityTypes; // default is nil. activity types listed will not be displayed

- (void)showWithCompletion:(CEMActivityViewControllerCompletionHandler)completionHandle;
@end


NS_ASSUME_NONNULL_END