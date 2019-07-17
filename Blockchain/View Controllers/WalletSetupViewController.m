//
//  WalletSetupViewController.m
//  Blockchain
//
//  Created by kevinwu on 3/27/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "WalletSetupViewController.h"
#import "Blockchain-Swift.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface WalletSetupViewController ()
@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UILabel *emailLabel;
@property (nonatomic, weak) UIWindow *window;
@end

@implementation WalletSetupViewController

- (id)init
{
    if (self = [super init]) {
        _window = [UIApplication sharedApplication].keyWindow;
    }
    return self;
}

- (void)loadView
{
    CGFloat safeAreaInsetBottom = [UIView rootViewSafeAreaInsets].bottom;
    CGRect frame = CGRectMake(0, 0, _window.frame.size.width, _window.frame.size.height - safeAreaInsetBottom);
    self.view = [[UIView alloc] initWithFrame:frame];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.view == nil) {
        [super loadView];
    }

    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.frame];
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollEnabled = NO;
    
    NSInteger numberOfPages = 2;
    
    [scrollView addSubview:[self setupEmailView]];
    
    scrollView.contentSize = CGSizeMake(self.view.frame.size.width * numberOfPages, scrollView.frame.size.height);
    [self.view addSubview:scrollView];
    
    self.scrollView = scrollView;
    [self goToSecondPage];
}

- (UIView *)setupEmailView
{
    UIView *emailView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height)];
    
    UIView *bannerView = [self setupBannerViewWithImageName:@"email"];
    [emailView addSubview:bannerView];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, bannerView.frame.size.height + 32, emailView.frame.size.width - 50, 50)];
    titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_EXTRA_LARGE];
    titleLabel.textColor = UIColor.gray5;
    titleLabel.text = BC_STRING_REMINDER_CHECK_EMAIL_TITLE;
    titleLabel.center = CGPointMake(emailView.center.x - self.view.frame.size.width, titleLabel.center.y);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [emailView addSubview:titleLabel];
    
    self.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, titleLabel.frame.origin.y + titleLabel.frame.size.height + 8, emailView.frame.size.width - 50, 30)];
    self.emailLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_SEMIBOLD size:FONT_SIZE_SMALL_MEDIUM];
    self.emailLabel.text = [WalletManager.sharedInstance.wallet getEmail];
    self.emailLabel.textColor = UIColor.gray5;
    self.emailLabel.center = CGPointMake(emailView.center.x - self.view.frame.size.width, self.emailLabel.center.y);
    self.emailLabel.textAlignment = NSTextAlignmentCenter;
    [emailView addSubview:self.emailLabel];
    
    UITextView *body = [[UITextView alloc] initWithFrame:CGRectMake(0, self.emailLabel.frame.origin.y + self.emailLabel.frame.size.height + 8, emailView.frame.size.width - 50, 100)];
    body.selectable = NO;
    body.editable = NO;
    body.scrollEnabled = NO;
    body.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    body.textColor = UIColor.gray5;
    body.text = BC_STRING_REMINDER_CHECK_EMAIL_MESSAGE;
    body.center = CGPointMake(emailView.center.x - self.view.frame.size.width, body.center.y);
    body.textAlignment = NSTextAlignmentCenter;
    [emailView addSubview:body];
    
    UIButton *openMailButton = [self setupActionButton];
    openMailButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    [openMailButton setTitle:[BC_STRING_OPEN_MAIL uppercaseString] forState:UIControlStateNormal];
    [openMailButton addTarget:self action:@selector(openMail) forControlEvents:UIControlEventTouchUpInside];
    [emailView addSubview:openMailButton];
    
    UIButton *doneButton = [self setupDoneButton];
    doneButton.layer.cornerRadius = CORNER_RADIUS_BUTTON;
    [doneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [emailView addSubview:doneButton];
    
    titleLabel.accessibilityIdentifier = AccessibilityIdentifiers_WalletSetupScreen.emailTitleLabel;
    self.emailLabel.accessibilityIdentifier = AccessibilityIdentifiers_WalletSetupScreen.emailEmailLabel;
    body.accessibilityIdentifier = AccessibilityIdentifiers_WalletSetupScreen.emailBodyTextView;
    openMailButton.accessibilityIdentifier = AccessibilityIdentifiers_WalletSetupScreen.emailOpenMailButton;
    doneButton.accessibilityIdentifier = AccessibilityIdentifiers_WalletSetupScreen.emailDoneButton;
    
    return emailView;
}

- (UIButton *)setupActionButton
{
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    actionButton.frame = CGRectMake(0, self.view.frame.size.height - 60 - 30 - 16, self.view.frame.size.width - 100, 40);
    actionButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    actionButton.center = CGPointMake(self.view.frame.size.width/2, actionButton.center.y);
    actionButton.backgroundColor = UIColor.brandSecondary;
    [actionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return actionButton;
}

- (UIButton *)setupDoneButton
{
    UIButton *doneButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60, self.view.frame.size.width - 100, 40)];
    doneButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_SMALL_MEDIUM];
    doneButton.center = CGPointMake(self.view.frame.size.width/2, doneButton.center.y);
    [doneButton setTitleColor:UIColor.gray2 forState:UIControlStateNormal];
    [doneButton setTitle:BC_STRING_ILL_DO_THIS_LATER forState:UIControlStateNormal];
    return doneButton;
}

- (UIView *)setupBannerViewWithImageName:(NSString *)imageName
{
    CGFloat safeAreaInsetTop = 20;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetTop = _window.rootViewController.view.safeAreaInsets.top;
    }

    CGFloat headerHeight = [ConstantsObjcBridge defaultNavigationBarHeight] + safeAreaInsetTop + 80;

    UIView *bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerHeight)];
    bannerView.backgroundColor = UIColor.brandPrimary;

    CGFloat imageHeight = 72;
    CGFloat imageWidth = 72;
    CGFloat posX = (bannerView.frame.size.width / 2) - (imageWidth / 2);
    CGFloat posY = (bannerView.frame.size.height / 2) - (imageHeight / 2) + (safeAreaInsetTop / 2);
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.frame = CGRectMake(posX, posY, imageWidth, imageHeight);
    
    [bannerView addSubview:imageView];
    return bannerView;
}

- (void)goToSecondPage
{
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width, 0) animated:YES];
}

- (void)dismiss
{
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:^{
        NSNotification *walletSetupCompleteNotification = [NSNotification notificationWithName:[ConstantsObjcBridge walletSetupDismissedNotification] object:nil];
        [[NSNotificationCenter defaultCenter] postNotification:walletSetupCompleteNotification];
    }];
}

- (void)openMail
{
    [UIApplication.sharedApplication openMailApplication];
}

@end
