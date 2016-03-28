//
//  CEMFileActivity.m
//  AirMonitor
//
//  Created by Sven on 3/14/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMFileActivity.h"

@implementation CEMFileActivity

- (instancetype)initWithFileData:(NSData *)data type:(NSString *)type {
    self = [super init];
    if (!self) return nil;
    _file = YES;
    _fileData = data;
    _fileType = type;
    return self;
}

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    _file = NO;
    return self;
}

+ (CEMActivityCategory)activityCategory { // default is CEMActivityCategoryAction.
    return CEMActivityCategoryShare;
}

@end
