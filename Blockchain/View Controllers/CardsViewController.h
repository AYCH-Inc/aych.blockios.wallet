//
//  DashboardViewController.h
//  Blockchain
//
//  Created by kevinwu on 8/23/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BridgedDisposeBag;
@class AnnouncementCardViewModel;
@class AnnouncementPresenter;

@interface CardsViewController : UIViewController

@property (nonatomic) CGFloat cardsViewHeight;
@property (nonatomic) UIView *dashboardContentView;
@property (nonatomic) UIScrollView *dashboardScrollView;

@property (nonatomic, strong) BridgedDisposeBag *disposeBag;
@property (nonatomic, strong) AnnouncementPresenter *announcementPresenter;

// This should be private or readonly, but it cannot be accessed
// from an extension.
@property (nonatomic) BOOL didShowCoinifyKycModal;

- (void)reloadWelcomeCards;
- (void)animateHideCards;
- (void)showSingleCardWithViewModel:(AnnouncementCardViewModel *)viewModel;

@end
