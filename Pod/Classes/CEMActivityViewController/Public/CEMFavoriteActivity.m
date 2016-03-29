//
//  CEMFavoriteActivity.m
//  Pods
//
//  Created by Sven on 3/25/16.
//
//

#import "CEMFavoriteActivity.h"
#import "CEMUtilities.h"

@implementation CEMFavoriteActivity

+ (CEMActivityCategory)activityCategory {
    return CEMActivityCategoryAction;
}

- (NSString *)activityTitle {
    return @"收藏";
}

- (NSString *)activityType {
    return CEMActivityTypeFavorite;
}

- (UIImage *)activityImage {
    return [UIImage cem_imageNamed:@"img_ss_favorite" inBundle:NSBundle.cem_libBundle];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    return YES;
}

- (void)performActivity {
    [self activityDidFinish:YES];
}

@end
