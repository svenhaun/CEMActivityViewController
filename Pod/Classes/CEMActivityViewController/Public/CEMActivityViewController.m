//
//  CEMActivityViewController.m
//  AirMonitor
//
//  Created by Sven on 3/5/16.
//  Copyright © 2016 SHENZHEN EVERBEST MACHINERY INDUSTRY CO.,LTD. All rights reserved.
//

#import "CEMActivityViewController.h"
#import "CEMOverlayWindow.h"

#import "CEMActivity+Private.h"
#import "CEMActivityViewCell.h"
#import "CEMUtilities.h"

///
@interface CEMActivityViewController () <UIGestureRecognizerDelegate,
UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,
CEMActivityDelegate>

@property(nullable, nonatomic, copy) CEMActivityViewControllerCompletionHandler completionWithItemsHandler; // set to nil after call

@property (nonatomic, copy) NSString* caption;

@property (nonatomic, weak) CEMOverlayWindow* backgroundWindow;
@property (nonatomic, weak) UIView* containerView;
@property (nonatomic, weak) UIButton* cancelButton;

//
@property (nonatomic, weak) UICollectionView* shareActivitiesCollectionView;
@property (nonatomic, weak) UICollectionView* actionActivitiesCollectionView;

// data
@property (nonatomic, retain) NSArray* activityItems;
@property (nonatomic, retain) NSMutableArray* applicationActivities;

//
@property (nonatomic, retain) NSArray* shareActivities;
@property (nonatomic, retain) NSArray* actionActivities;

@end

static NSArray* _defaAppActivities = nil;
const float _itemHeight = 94.f;

@implementation CEMActivityViewController

+ (void)initialize {
    if (self == CEMActivityViewController.class) {
        _defaAppActivities = @[CEMActivityTypePostToWeChat, CEMActivityTypePostToWeChatTimeline,
                               CEMActivityTypePostToQQ, CEMActivityTypePostToQzone,
                               CEMActivityTypePostToWeibo,
                               CEMActivityTypeMail, CEMActivityTypeMessage, CEMActivityTypeOpenInSafari,
                               CEMActivityTypeRefreshWeb, CEMActivityTypeTrash, CEMActivityTypeFavorite,
                               CEMActivityTypeIllegalReport, CEMActivityTypeSaveToLocal];
    }
}

- (instancetype)initWithTitle:(nullable NSString *)title activityItems:(nullable NSArray *)activityItems applicationActivities:(NSArray<__kindof CEMActivity *> *)applicationActivities {
    self = [super initWithNibName:nil bundle:nil];
    if (!self) return nil;
    // window
    _backgroundWindow = [CEMOverlayWindow window];
    _activityItems = activityItems;
    _applicationActivities = [NSMutableArray arrayWithArray:applicationActivities];
    _caption = title.copy;
    
    [self prehandleTitle];
    [self prehandleActivities];
    
    return self;
}

- (void)loadView {
    [super loadView];
    self.view.backgroundColor = UIColor.clearColor;
    UIView* container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 16*2+50)];
    [self.view addSubview:container];
    container.backgroundColor = [UIColor colorWithWhite:1. alpha:0.]; //[UIColor colorWithWhite:250/255.0 alpha:1];
    container.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    self.containerView = container;
    
    if ( NSClassFromString(@"UIBlurEffect")) {
        
        UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView* visualEffect = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffect.frame = container.bounds;
        visualEffect.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        [self.containerView addSubview:visualEffect];
    }
    else {
        container.backgroundColor = [UIColor colorWithWhite:210/255.0 alpha:1];
    }
    
    // title
    if (_caption.length) {
        CGRect frame = container.frame;
        frame.size.height += 30;
        container.frame = frame;
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.containerView.frame), 30)];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.text = _caption;
        titleLabel.textColor = [UIColor colorWithWhite:93./255 alpha:1.];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.containerView addSubview:titleLabel];
    }
    
    //
    UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(0, CGRectGetHeight(self.containerView.frame)-50, CGRectGetWidth(self.containerView.frame), 50);
    cancelButton.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage cem_imageFromColor:[UIColor colorWithWhite:230./255 alpha:1.]] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage cem_imageFromColor:[UIColor colorWithWhite:225./255 alpha:1.]] forState:UIControlStateHighlighted];
    [cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:cancelButton];
    self.cancelButton = cancelButton;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer* tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapWindow:)];
    tapGR.delegate = self;
    [self.view addGestureRecognizer:tapGR];
    
    [self initAndLoadContents];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark __PUB__
- (void)showWithCompletion:(CEMActivityViewControllerCompletionHandler)completionHandle {
    self.completionWithItemsHandler = completionHandle;

    _backgroundWindow.rootViewController = self;
    [_backgroundWindow makeKeyAndVisible];
    
    self.containerView.center = CGPointMake(CGRectGetMidX(self.containerView.bounds),
                                            CGRectGetHeight(self.view.bounds)+CGRectGetHeight(self.containerView.bounds)/2.);
    _backgroundWindow.alpha = 0;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.containerView.center = CGPointMake(CGRectGetMidX(self.containerView.bounds),
                                                CGRectGetHeight(self.view.bounds)-CGRectGetHeight(self.containerView.bounds)/2.);
        _backgroundWindow.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)setExcludedActivityTypes:(NSArray<NSString *> *)excludedActivityTypes {
    if (_excludedActivityTypes != excludedActivityTypes) {
        _excludedActivityTypes = excludedActivityTypes.copy;
        
        [self handleActivities];
    }
}

#pragma mark __PRI__Action_
- (void)tapWindow:(UITapGestureRecognizer *)tapGR {
    if (!_backgroundWindow.isKeyWindow) return;
    [self dismissWithActity:nil orCancel:YES];
}

- (void)cancel:(id)sender {
    [self dismissWithActity:nil orCancel:YES];
}

#pragma mark __PRI__View_
- (void)initAndLoadContents {
    
    BOOL hasShare, hasAction;
    hasShare = self.shareActivities.count != 0;
    hasAction = self.actionActivities.count != 0;
    
    //
    CGRect frame = self.containerView.frame;
    CGFloat yOffset = self.caption.length ? 30 + 16 : 16;
    
    //
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    if (hasShare) {
        frame.size.height += _itemHeight + (hasAction ? 16 : 0);
        self.containerView.frame = frame;
        //
        UICollectionView* cv = [[UICollectionView alloc] initWithFrame:CGRectMake(0, yOffset, CGRectGetWidth(frame), _itemHeight)
                                                  collectionViewLayout:layout];
        cv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        cv.backgroundColor = [UIColor clearColor];
        cv.alwaysBounceHorizontal = YES;
        cv.showsHorizontalScrollIndicator = NO;
        [self.containerView addSubview:cv];
        
        cv.delegate = self;
        cv.dataSource = self;
        [cv registerClass:CEMActivityViewCell.class forCellWithReuseIdentifier:@"CEMActivityViewCellID"];
        
        self.shareActivitiesCollectionView = cv;
        yOffset += _itemHeight + 16 * 2;
    }
    
    if (hasAction) {
        frame.size.height += _itemHeight + (hasShare ? 16 : 0);
        self.containerView.frame = frame;
        
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView* cv = [[UICollectionView alloc] initWithFrame:CGRectMake(0, yOffset, CGRectGetWidth(frame), _itemHeight)
                                                  collectionViewLayout:layout];
        cv.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
        cv.backgroundColor = [UIColor clearColor];
        cv.alwaysBounceHorizontal = YES;
        cv.showsHorizontalScrollIndicator = NO;
        [self.containerView addSubview:cv];
        
        cv.delegate = self;
        cv.dataSource = self;
        [cv registerClass:CEMActivityViewCell.class forCellWithReuseIdentifier:@"CEMActivityViewCellID"];
        self.actionActivitiesCollectionView = cv;
    }
    
    if (hasAction && hasShare) {
        UIView* line = [[UIView alloc] initWithFrame:CGRectMake(15, 0, CGRectGetWidth(frame)-15, 1)];
        line.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleLeftMargin;
        line.center = CGPointMake(CGRectGetMidX(frame)+7.5, CGRectGetMidY(frame)-10);
        [self.containerView addSubview:line];
        
        line.userInteractionEnabled = NO;
        line.backgroundColor = [UIColor colorWithRed:198./255 green:194./255 blue:191./255 alpha:.8f];
    }
}

#pragma mark __PRI__DATA__
- (void)prehandleTitle {
    if (_caption.length) return;
    
    for (NSObject* obj in self.activityItems) {
        if ([obj.class isSubclassOfClass:NSURL.class]) {
            _caption = [NSString stringWithFormat:@"网页有%@提供", ((NSURL *)obj).host];
            break;
        }
    }
}

- (void)prehandleActivities {
    if (!self.applicationActivities.count) {
        for (NSString* activityType in _defaAppActivities) {
            CEMActivity* activity = [CEMActivity activityWithType:activityType];
            if ([activity canPerformWithActivityItems:self.activityItems]) {
                [self.applicationActivities addObject:activity];
            }
        }
    }
    
    [self handleActivities];
}

- (void)handleActivities {
    
    NSMutableArray* toRemove = [NSMutableArray array];
    NSMutableArray* shareActivities, *actionActivities;
    shareActivities = [NSMutableArray array];
    actionActivities = [NSMutableArray array];
    
    [self.applicationActivities enumerateObjectsUsingBlock:^(CEMActivity*  _Nonnull activity, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([self.excludedActivityTypes containsObject:activity.activityType]) {
            [toRemove addObject:activity];
        }
        else {
            CEMActivityCategory category = (CEMActivityCategory)[activity.class activityCategory];
            NSMutableArray* curArr = @[actionActivities, shareActivities][category];
            [curArr addObject:activity];
        }
    }];
    
    [self.applicationActivities removeObjectsInArray:toRemove];
    self.shareActivities = shareActivities;
    self.actionActivities = actionActivities;
}

#pragma mark __PRI__NOTY_
- (void)dismissWithActity:(NSString *)activityType orCancel:(BOOL)cancel {
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.containerView.center = CGPointMake(CGRectGetMidX(self.containerView.bounds),
                                                CGRectGetHeight(self.view.bounds)+CGRectGetHeight(self.containerView.bounds)/2.);
        _backgroundWindow.alpha = 0.f;
    } completion:^(BOOL finished) {
        [_backgroundWindow revertKeyWindowAndHidden];
        _backgroundWindow.rootViewController = nil;
        
        for (UIGestureRecognizer* gr in _backgroundWindow.gestureRecognizers) {
            if ([gr isKindOfClass:UITapGestureRecognizer.class]) {
                [_backgroundWindow removeGestureRecognizer:gr];
            }
        }
        
        if (self.completionWithItemsHandler) {
            self.completionWithItemsHandler(activityType, !cancel);
        }
    }];
}

- (void)activeActivity:(CEMActivity *)activity {
    if (!activity) {
        [self dismissWithActity:nil orCancel:YES];
        return;
    }
    
    activity.delegate = self;
    if ([activity canPerformWithActivityItems:self.activityItems]) {
        [activity prepareWithActivityItems:self.activityItems];
        UIViewController* vc = [activity activityViewController];
        if (!vc) {
            [activity performActivity];
        }
        else {
            [self presentViewController:vc animated:YES completion:NULL];
        }
    }
    else {
        [self dismissWithActity:activity.activityType orCancel:NO];
    }
}

#pragma mark __ActivityDelegate__
- (void)activity:(CEMActivity *)activity didFinish:(BOOL)completed {
    activity.delegate = nil;
    
    [self dismissWithActity:activity.activityType orCancel:!completed];
}

#pragma mark __UIGestureRecognizer
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return ![touch.view isDescendantOfView:self.containerView];
}

#pragma mark __UICollectionViewDelegate__UICollectionViewDataSource__
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.shareActivitiesCollectionView) return self.shareActivities.count;
    else return self.actionActivities.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CEMActivityViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CEMActivityViewCellID"
                                                                          forIndexPath:indexPath];
    if (collectionView == self.shareActivitiesCollectionView) {
        cell.activity = self.shareActivities[indexPath.row];
    }
    else {
        cell.activity = self.actionActivities[indexPath.row];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    CEMActivityViewCell* cell = (CEMActivityViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [self activeActivity:cell.activity];
}

#pragma mark __Layout_
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(60, _itemHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 15, 0, 15);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 12;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

@end


