//
//  CEMFileActivity.h
//  AirMonitor
//
//  Created by Sven on 3/14/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMActivity.h"

@interface CEMFileActivity : CEMActivity
@property (nonatomic, assign, getter=isFile) BOOL file; // default: NO
@property (nonatomic, retain) NSString* fileType;  // pdf, png, ec. def: pdf
@property (nonatomic, retain) NSData* fileData;

- (instancetype)initWithFileData:(NSData *)data type:(NSString *)type;
@end
