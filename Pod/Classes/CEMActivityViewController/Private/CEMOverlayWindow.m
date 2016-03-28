//
//  CEMOverlayWindow.m
//  AirMonitor
//
//  Created by Sven on 3/5/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMOverlayWindow.h"

const UIWindowLevel CEMWindowLevelActivityViewController = 3001;


///
@interface CEMOverlayWindow ()
@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, strong) UIWindow *previousKeyWindow;
@property (nonatomic, assign) UIViewTintAdjustmentMode oldTintAdjustmentMode;
@end


@implementation CEMOverlayWindow


+(instancetype)window {
    static CEMOverlayWindow* window;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        window = [[self alloc] init];
    });
    
    return window;
}

- (id)init { return [self initWithFrame:[[UIScreen mainScreen] bounds]]; }

- (id)initWithFrame:(CGRect)frame {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self = [super initWithFrame:CGRectMake(0, 0, MIN(screenSize.width, screenSize.height), MAX(screenSize.width, screenSize.height))];
    if (!self) return nil;
    
    self.windowLevel = CEMWindowLevelActivityViewController;
    self.hidden = YES;
    self.userInteractionEnabled = NO;
    self.backgroundColor = UIColor.clearColor;
    
    UIView* backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView = backgroundView;
    self.backgroundView.backgroundColor = [UIColor colorWithWhite:0. alpha:0.24f];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.backgroundView];

    return self;
}

- (void)setAlpha:(CGFloat)alpha {
    self.backgroundView.alpha = alpha;
}

- (void)makeKeyWindow {
    if (!self.isKeyWindow) {
        
        self.hidden = NO;
        self.userInteractionEnabled = YES;
        
        _previousKeyWindow = [[UIApplication sharedApplication] keyWindow];
        if ([_previousKeyWindow respondsToSelector:@selector(setTintAdjustmentMode:)]) { // for iOS 7
            self.oldTintAdjustmentMode = _previousKeyWindow.tintAdjustmentMode;
            _previousKeyWindow.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        }
    }
    
    [super makeKeyWindow];
}

- (void)revertKeyWindowAndHidden {
    self.hidden = YES;
    
    if ([_previousKeyWindow respondsToSelector:@selector(setTintAdjustmentMode:)]) {
        _previousKeyWindow.tintAdjustmentMode = self.oldTintAdjustmentMode;
    }
    if (self.isKeyWindow) {
        [_previousKeyWindow makeKeyWindow];
    }
    _previousKeyWindow = nil;
}

@end
