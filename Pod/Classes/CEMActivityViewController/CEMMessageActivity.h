//
//  CEMMessageActivity.h
//  AirMonitor
//
//  Created by Sven on 3/7/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMActivity.h"

@interface CEMMessageActivity : CEMActivity
@property (nonatomic, assign) CGFloat imageAttachCompressScale;  // default: 0.5
@property (nonatomic, copy) NSString* subject; // default: contained in activityItems : first NSString
@property (nonatomic, copy) NSString* body;   // default: equal to subject
@end


////
@interface CEMMailActivity : CEMActivity
@property (nonatomic, assign) CGFloat imageAttachCompressScale;  // default: 0.5
@property (nonatomic, copy) NSString* subject; // default: contained in activityItems : first NSString
@property (nonatomic, copy) NSString* body;   // default: equal to subject
@end
