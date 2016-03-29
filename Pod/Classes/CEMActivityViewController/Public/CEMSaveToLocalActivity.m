//
//  CEMSaveToLocalActivity.m
//  Pods
//
//  Created by Sven on 3/25/16.
//
//

#import "CEMSaveToLocalActivity.h"
#import "CEMUtilities.h"


@implementation CEMSaveToLocalActivity

+ (CEMActivityCategory)activityCategory {
    return CEMActivityCategoryAction;
}

- (NSString *)activityTitle {
    return @"本地保存";
}

- (NSString *)activityType {
    return CEMActivityTypeSaveToLocal;
}

- (UIImage *)activityImage {
    return [UIImage cem_imageNamed:@"img_ss_local" inBundle:NSBundle.cem_libBundle];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)performActivity {
    [self activityDidFinish:YES];
}

@end
