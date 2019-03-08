//
//  DashboardViewController.h
//  Blockchain
//
//  Created by kevinwu on 8/23/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AnnouncementCardViewModel;

@interface CardsViewController : UIViewController
// TICKET: IOS-1249 - Refactor CardsViewController
@property (nonatomic) CGFloat cardsViewHeight;
@property (nonatomic) UIView *dashboardContentView;
@property (nonatomic) UIScrollView *dashboardScrollView;

// This should be private or readonly, but it cannot be accessed
// from an extension.
@property (nonatomic) BOOL didShowCoinifyKycModal;

- (void)reloadWelcomeCards;
- (void)animateHideCards;
- (void)showSingleCardWithViewModel:(AnnouncementCardViewModel *)viewModel;

// Actions
- (void)stellarAirdropCardActionTapped;
- (void)stellarModalKycCompletedActionTapped;
- (void)coinifyKycActionTapped;
@end
