//
//  CEMViewController.m
//  CEMActivityViewController
//
//  Created by svenhaun on 03/16/2016.
//  Copyright (c) 2016 svenhaun. All rights reserved.
//

#import "CEMViewController.h"
#import <Foundation/Foundation.h>
#import <CEMActivityViewController/CEMActivityViewController.h>


@interface CEMViewController ()

@end

@implementation CEMViewController

- (IBAction)share:(id)sender {
    NSArray* shareItems = @[@"Hello World", [NSURL URLWithString:@"http://www.helloworld.com"], [UIImage imageNamed:@"logo"]];
    
    CEMActivityViewController* activityVC = [[CEMActivityViewController alloc] initWithTitle:@"分享方式" activityItems:shareItems
                                                                       applicationActivities:nil];
    [activityVC showWithCompletion:^(NSString * _Nullable activityType, BOOL completed) {
        
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
