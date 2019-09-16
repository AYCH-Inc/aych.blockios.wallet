//
//  AccountsAndAddressesNavigationController.m
//  Blockchain
//
//  Created by Kevin Wu on 1/12/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import "AccountsAndAddressesNavigationController.h"
#import "AccountsAndAddressesViewController.h"
#import "AccountsAndAddressesDetailViewController.h"
#import "SendBitcoinViewController.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"

@interface AccountsAndAddressesNavigationController () <AssetSelectorViewDelegate, WalletAddressesDelegate>
@property (nonatomic, readwrite) AssetSelectorView *assetSelectorView;
@property (nonatomic) BOOL isOpeningSelector;
@end

@implementation AccountsAndAddressesNavigationController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGFloat safeAreaInsetTop = UIView.rootViewSafeAreaInsets.top;
    CGFloat navBarHeight = [ConstantsObjcBridge defaultNavigationBarHeight];

    self.view.frame = [UIView rootViewSafeAreaFrameWithNavigationBar:YES tabBar:NO assetSelector:YES];

    [self.navigationBar setTitleTextAttributes:[UINavigationBar largeTitleTextAttributes]];
    self.warningButton = [[UIBarButtonItem alloc]
                          initWithImage:[UIImage imageNamed:@"warning"]
                          style:UIBarButtonItemStylePlain
                          target:self action:@selector(transferAllFundsWarningClicked)];

    WalletManager.sharedInstance.addressesDelegate = self;
    
    CGRect selectorFrame = CGRectMake(0,
                                      safeAreaInsetTop + navBarHeight,
                                      self.view.frame.size.width,
                                      [ConstantsObjcBridge assetTypeCellHeight]);
    
    self.assetSelectorView = [[AssetSelectorView alloc]
                              initWithFrame:selectorFrame
                              assets:@[[NSNumber numberWithInteger:LegacyAssetTypeBitcoin], [NSNumber numberWithInteger:LegacyAssetTypeBitcoinCash]]
                              parentView: self.view];
    self.assetSelectorView.delegate = self;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.isOpeningSelector) { return; }
}

- (void)reload
{
    if (![self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]] &&
        ![self.visibleViewController isMemberOfClass:[AccountsAndAddressesDetailViewController class]]) {
        [self popViewControllerAnimated:YES];
    }
    
    if (!self.view.window) {
        [self popToRootViewControllerAnimated:NO];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_KEY_RELOAD_ACCOUNTS_AND_ADDRESSES object:nil];
}

- (void)alertUserToTransferAllFunds:(BOOL)userClicked
{
    AppFeatureConfiguration *transferFundsConfig = [AppFeatureConfigurator.sharedInstance configurationFor:AppFeatureTransferFundsFromImportedAddress];
    if (!transferFundsConfig.isEnabled) {
        return;
    }

    UIAlertController *alertToTransfer = [UIAlertController alertControllerWithTitle:BC_STRING_TRANSFER_FUNDS message:[NSString stringWithFormat:@"%@\n\n%@", BC_STRING_TRANSFER_FUNDS_DESCRIPTION_ONE, BC_STRING_TRANSFER_FUNDS_DESCRIPTION_TWO] preferredStyle:UIAlertControllerStyleAlert];
    [alertToTransfer addAction:[UIAlertAction actionWithTitle:BC_STRING_NOT_NOW style:UIAlertActionStyleCancel handler:nil]];
    [alertToTransfer addAction:[UIAlertAction actionWithTitle:BC_STRING_TRANSFER_FUNDS style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self transferAllFundsClicked];
    }]];
    
    if (!userClicked) {
        [alertToTransfer addAction:[UIAlertAction actionWithTitle:[LocalizationConstantsObjcBridge dontShowAgain] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            BlockchainSettings.sharedAppInstance.hideTransferAllFundsAlert = YES;
        }]];
    }
    
    [self presentViewController:alertToTransfer animated:YES completion:nil];
}

#pragma mark - Transfer Funds

- (void)transferAllFundsWarningClicked
{
    [self alertUserToTransferAllFunds:YES];
}

- (void)transferAllFundsClicked
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[AppCoordinator sharedInstance] closeSideMenu];
    }];
    
    [[TransferAllCoordinator sharedInstance] startWithSendScreen];
}

#pragma mark - Navigation

- (void)resetAddressesViewControllerContainerFrame
{
    if ([self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]]) {
        AccountsAndAddressesViewController *accountsAndAddressesViewController = (AccountsAndAddressesViewController *)self.visibleViewController;
        [accountsAndAddressesViewController.containerView changeYPosition:8 + [ConstantsObjcBridge assetTypeCellHeight]];
    }
}

#pragma mark - Asset Selector View Delegate

- (void)didSelectAsset:(LegacyAssetType)assetType
{
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self resetAddressesViewControllerContainerFrame];
    }];
    
    if ([self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]]) {
        AccountsAndAddressesViewController *accountsAndAddressesViewController = (AccountsAndAddressesViewController *)self.visibleViewController;
        accountsAndAddressesViewController.assetType = assetType;
    };
}

- (void)didOpenSelector
{
    self.isOpeningSelector = YES;

    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        if ([self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]]) {
            AccountsAndAddressesViewController *accountsAndAddressesViewController = (AccountsAndAddressesViewController *)self.visibleViewController;
            [accountsAndAddressesViewController.containerView changeYPosition:8 + [ConstantsObjcBridge assetTypeCellHeight]*self.assetSelectorView.assets.count];
        }
    } completion:^(BOOL finished) {
        self.isOpeningSelector = NO;
    }];
}

#pragma mark WalletAddressesDelegate

- (void)didSetDefaultAccount
{
    [AssetAddressRepository.sharedInstance removeAllSwipeAddressesFor:AssetTypeBitcoin];
    [AssetAddressRepository.sharedInstance removeAllSwipeAddressesFor:AssetTypeBitcoinCash];
    [AppCoordinator.sharedInstance.tabControllerManager didSetDefaultAccount];
}

- (void)didGenerateNewAddress
{
    if ([self.visibleViewController isMemberOfClass:[AccountsAndAddressesViewController class]]) {
        AccountsAndAddressesViewController *accountsAndAddressesViewController = (AccountsAndAddressesViewController *)self.visibleViewController;
        [accountsAndAddressesViewController didGenerateNewAddress];
    }
}

- (void)returnToAddressesScreen
{
    [self popToRootViewControllerAnimated:YES];
}

@end
