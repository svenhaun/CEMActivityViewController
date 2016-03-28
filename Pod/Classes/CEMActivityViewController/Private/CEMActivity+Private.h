//
//  CEMActivity+Private.h
//  AirMonitor
//
//  Created by Sven on 3/7/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMActivity.h"

@protocol CEMActivityDelegate <NSObject>
- (void)activity:(CEMActivity *)activity didFinish:(BOOL)completed;
@end


@interface CEMActivity (Private)
@property (nonatomic, weak) id<CEMActivityDelegate> delegate;

+ (instancetype)activityWithType:(NSString *)type;
@end
