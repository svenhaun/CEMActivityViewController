//
//  CEMUtilities.h
//  Pods
//
//  Created by Sven on 3/25/16.
//
//

#import <Foundation/Foundation.h>

@interface UIImage (CEMUtilities)
+ (UIImage *)cem_imageNamed:(NSString *)name inBundle:(NSString *)bundleName;
+ (UIImage *)cem_imageFromColor:(UIColor *)color;
//
- (UIImage *)cem_imageByRoundCornerRadius:(CGFloat)radius;
- (UIImage *)cem_highlightImage;

@end


///
@interface NSDate (CEMDateFormat)
- (NSString *)cem_stringWithFormat:(NSString *)format;
@end

