//
//  CEMActivityViewCell.m
//  AirMonitor
//
//  Created by Sven on 3/7/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMActivityViewCell.h"
#import "CEMActivity.h"


@interface UIImage (CreateHighlightImage)
- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius;
- (UIImage *)highlightImage;
@end

//
@interface CEMActivityViewCell ()
@property (nonatomic, weak) UIImageView* indexIView;
@property (nonatomic, weak) UILabel* titleLabel;
@end


@implementation CEMActivityViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    [self initSubviews];
    return self;
}

- (void)prepareForReuse {
    self.indexIView.image = nil;
    self.indexIView.highlightedImage = nil;
    self.titleLabel.text = nil;
    [super prepareForReuse];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.indexIView.highlighted = highlighted;
}

#pragma mark __PRI__SUBVIEWS__
- (void)initSubviews {
    UIImageView* indexIView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    indexIView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    indexIView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:indexIView];
    self.indexIView = indexIView;
    
    // label
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 60+4, 60, 30)];
    titleLabel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor colorWithWhite:90./255 alpha:1.];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
}

- (void)setActivity:(CEMActivity *)activity {
    _activity = activity;
    
    UIImage* faceImage = [activity activityImage];
    self.indexIView.image = [faceImage imageByRoundCornerRadius:13.f];
    self.indexIView.highlightedImage = [faceImage.highlightImage imageByRoundCornerRadius:13.f];
    
    self.titleLabel.text = [activity activityTitle];
}

@end


/////
@implementation UIImage (CreateHighlightImage)

- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius {
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -rect.size.height);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, 0)];
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