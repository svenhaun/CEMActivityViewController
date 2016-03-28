//
//  CEMUtilities.h
//  Pods
//
//  Created by Sven on 3/25/16.
//
//

#import <Foundation/Foundation.h>

@interface UIImage (CEMUtilities)
+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSString *)bundleName;

//
- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius;
- (UIImage *)highlightImage;

@end


///
@interface NSDate (CEMDateFormat)
- (NSString *)stringWithFormat:(NSString *)format;
@end

