//
//  CEMIllegalReportActivity.m
//  Pods
//
//  Created by Sven on 3/25/16.
//
//

#import "CEMIllegalReportActivity.h"
#import "CEMUtilities.h"

@implementation CEMIllegalReportActivity

+ (CEMActivityCategory)activityCategory {
    return CEMActivityCategoryAction;
}

- (NSString *)activityTitle {
    return @"举报";
}

- (NSString *)activityType {
    return CEMActivityTypeIllegalReport;
}

- (UIImage *)activityImage {
    return [UIImage cem_imageNamed:@"img_ss_report" inBundle:NSBundle.cem_libBundle];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)performActivity {
    [self activityDidFinish:YES];
}

@end
