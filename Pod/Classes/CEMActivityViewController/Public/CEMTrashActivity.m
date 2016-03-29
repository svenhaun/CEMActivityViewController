//
//  CEMTrashActivity.m
//  Pods
//
//  Created by Sven on 3/25/16.
//
//

#import "CEMTrashActivity.h"
#import "CEMUtilities.h"


@implementation CEMTrashActivity

+ (CEMActivityCategory)activityCategory {
    return CEMActivityCategoryAction;
}

- (NSString *)activityTitle {
    return @"删除";
}

- (NSString *)activityType {
    return CEMActivityTypeTrash;
}

- (UIImage *)activityImage {
    return [UIImage cem_imageNamed:@"img_ss_delete" inBundle:@"Resource"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)performActivity {
    [self activityDidFinish:YES];
}

@end
