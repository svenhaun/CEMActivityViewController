//
//  CEMOverlayWindow.h
//  AirMonitor
//
//  Created by Sven on 3/5/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CEMOverlayWindow : UIWindow

+ (instancetype)window;

- (void)revertKeyWindowAndHidden;

@property (nonatomic, readonly) UIWindow *previousKeyWindow;

@end
