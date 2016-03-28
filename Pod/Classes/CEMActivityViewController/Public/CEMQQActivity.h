//
//  CEMQQActivity.h
//  AirMonitor
//
//  Created by Sven on 3/7/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMFileActivity.h"

@interface CEMQQActivity : CEMActivity
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* describe;
@property (nonatomic, retain) NSString* sourceURL;
@property (nonatomic, retain) UIImage* oriImage;
@end


////
@interface CEMQQzoneActivity : CEMActivity
@property (nonatomic, retain, readonly) NSString* sourceURL;

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* describe;
@property (nonatomic, retain) UIImage* previewImage;
@end
