//
//  CEMActivityViewCell.m
//  AirMonitor
//
//  Created by Sven on 3/7/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMActivityViewCell.h"
#import "CEMActivity.h"
#import "CEMUtilities.h"

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
    self.indexIView.image = [faceImage cem_imageByRoundCornerRadius:13.f];
    self.indexIView.highlightedImage = [faceImage.cem_highlightImage cem_imageByRoundCornerRadius:13.f];
    
    self.titleLabel.text = [activity activityTitle];
}

@end
