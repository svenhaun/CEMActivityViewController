//
//  CEMUtilities.m
//  Pods
//
//  Created by Sven on 3/25/16.
//
//

#import "CEMUtilities.h"

@implementation UIImage (CEMUtilities)

+ (UIImage *)imageNamed:(NSString *)name inBundle:(NSString *)bundleName {
    if (!name) return nil;
    if (!bundleName) return [UIImage imageNamed:name];

    NSString* bundlePath = [NSBundle.mainBundle pathForResource:bundleName ofType:@"bundle"];
    NSBundle* bundle = [NSBundle bundleWithPath:bundlePath];
    if (!bundle) return [UIImage imageNamed:name];
    
    int screenScale = [UIScreen mainScreen].scale;
    
    NSString* imageExt = name.pathExtension;
    if (!imageExt.length) imageExt = @"png";
    NSString* nameWithoutExt = name.stringByDeletingPathExtension;
    
    NSString* imageFullpath;
    NSRange atRange = [nameWithoutExt rangeOfString:@"@"];
    if (atRange.location == NSNotFound) {
        NSString* nameWithoutAt = nameWithoutExt;
    
        nameWithoutExt = [NSString stringWithFormat:@"%@@%dx", nameWithoutExt, screenScale];
        imageFullpath = [bundle pathForResource:nameWithoutExt ofType:imageExt];
        if (imageFullpath) return [UIImage imageWithContentsOfFile:imageFullpath];
        
        // dont find proper
        imageFullpath = [bundle pathForResource:nameWithoutAt ofType:imageExt];
        if (imageFullpath) return [UIImage imageWithContentsOfFile:imageFullpath];
        return nil;
    }

    imageFullpath = [bundle pathForResource:nameWithoutExt ofType:imageExt];
    if (!imageFullpath) return nil;
    return [UIImage imageWithContentsOfFile:imageFullpath];
}

- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius {
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners
                                                     cornerRadii:CGSizeMake(radius, 0)];
    [path closePath];
    
    CGContextSaveGState(context);
    [path addClip];
    CGContextDrawImage(context, rect, self.CGImage);
    CGContextRestoreGState(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)highlightImage {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    UIColor* overlayColor = [UIColor colorWithWhite:0 alpha:0.3];
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self drawInRect:rect];
    
    CGContextSetFillColorWithColor(context, overlayColor.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end


////
///
@implementation NSDate (CEMDateFormat)

- (NSString *)stringWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setLocale:[NSLocale currentLocale]];
    return [formatter stringFromDate:self];
}

@end

