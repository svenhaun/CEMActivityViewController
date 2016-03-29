//
//  CEMUtilities.h
//  Pods
//
//  Created by Sven on 3/25/16.
//
//

#import <Foundation/Foundation.h>

@interface UIImage (CEMUtilities)
+ (UIImage *)cem_imageNamed:(NSString *)name inBundle:(NSBundle *)bundle;
+ (UIImage *)cem_imageFromColor:(UIColor *)color;
//
- (UIImage *)cem_imageByRoundCornerRadius:(CGFloat)radius;
- (UIImage *)cem_highlightImage;

@end

@interface NSBundle (CEMUtilities)

+ (NSBundle *)cem_libBundle;
+ (NSURL *)cem_libBundleURL;
@end


///
@interface NSDate (CEMDateFormat)
- (NSString *)cem_stringWithFormat:(NSString *)format;
@end

