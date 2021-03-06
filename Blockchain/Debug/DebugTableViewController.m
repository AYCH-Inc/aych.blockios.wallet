//
//  DebugTableViewController.m
//  Blockchain
//
//  Created by Kevin Wu on 12/29/15.
//  Copyright © 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import "DebugTableViewController.h"
#import "Blockchain-Swift.h"

#define DICTIONARY_KEY_SERVER @"server"
#define DICTIONARY_KEY_WEB_SOCKET @"webSocket"
#define DICTIONARY_KEY_API @"api"
#define DICTIONARY_KEY_BUY_WEBVIEW @"buyWebView"

typedef NS_ENUM(NSInteger, DebugTableViewRow) {
    RowWalletJSON = 0,
    RowSurgeToggle,
    RowDontShowAgain,
    RowCertificatePinning,
    RowSecurityReminderTimer,
    RowZeroTickerValue,
    RowCreateWalletPrefill,
    RowCreateWalletCustomEmail,
    RowUseHomebrewForExchange,
    RowMockExchangeOrderDepositAddress,
    RowMockExchangeDeposit,
    RowTotalCount,
};

typedef enum {
    env_dev = 0,
    env_staging = 1,
    env_production = 2,
    env_testnet = 3
} environment;

@interface DebugTableViewController ()
@property (nonatomic) NSDictionary *filteredWalletJSON;

@end

@implementation DebugTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UISegmentedControl *control = [[UISegmentedControl alloc] initWithItems:@[@"Dev", @"Staging", @"Production", @"Testnet"]];
    
    NSInteger environment = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_ENV] integerValue];
    
    if (environment) {
        control.selectedSegmentIndex = environment;
    } else {
        control.selectedSegmentIndex = env_dev;
    }
    
    control.tintColor = [UIColor whiteColor];
    
    [control addTarget:self action:@selector(selectEnvironment:) forControlEvents:UIControlEventValueChanged];
    
    self.navigationItem.titleView = control;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BC_STRING_DONE style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    self.navigationController.navigationBar.barTintColor = UIColor.brandPrimary;
    NSString *presenter;
    switch (self.presenter) {
        case welcome:
            presenter = DEBUG_STRING_WELCOME;
        case pin:
            presenter = BC_STRING_SETTINGS_VERIFY;
        case settings:
            presenter = BC_STRING_SETTINGS_ABOUT;
    }
    self.navigationItem.title = [NSString stringWithFormat:@"%@ %@ %@", DEBUG_STRING_DEBUG, DEBUG_STRING_FROM_LOWERCASE, presenter];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.filteredWalletJSON = [WalletManager.sharedInstance.wallet filteredWalletJSON];
}

- (void)dismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectEnvironment:(UISegmentedControl *)control
{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:control.selectedSegmentIndex] forKey:USER_DEFAULTS_KEY_ENV];
    
    [self.tableView reloadData];
}

- (void)alertToChangeURLName:(NSString *)name userDefaultKey:(NSString *)key currentURL:(NSString *)currentURL
{
    UIAlertController *changeURLAlert = [UIAlertController alertControllerWithTitle:name message:nil preferredStyle:UIAlertControllerStyleAlert];
    [changeURLAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        BCSecureTextField *secureTextField = (BCSecureTextField *)textField;
        secureTextField.text = currentURL;
        secureTextField.returnKeyType = UIReturnKeyDone;
    }];
    [changeURLAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        BCSecureTextField *secureTextField = (BCSecureTextField *)[[changeURLAlert textFields] firstObject];
        [[NSUserDefaults standardUserDefaults] setObject:secureTextField.text forKey:key];
        [self.tableView reloadData];
    }]];
    [changeURLAlert addAction:[UIAlertAction actionWithTitle:DEBUG_STRING_RESET style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
        [self.tableView reloadData];
    }]];
    [changeURLAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:changeURLAlert animated:YES completion:nil];
}

- (void)toggleSurge
{
    BOOL surgeOn = [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_DEBUG_SIMULATE_SURGE];
    [[NSUserDefaults standardUserDefaults] setBool:!surgeOn forKey:USER_DEFAULTS_KEY_DEBUG_SIMULATE_SURGE];
}

- (void)togglePinning
{
    BOOL pinningOn = [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_DEBUG_ENABLE_CERTIFICATE_PINNING];
    [[NSUserDefaults standardUserDefaults] setBool:!pinningOn forKey:USER_DEFAULTS_KEY_DEBUG_ENABLE_CERTIFICATE_PINNING];
}

- (void)toggleZeroTicker
{
    BOOL zeroTickerOn = [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_DEBUG_SIMULATE_ZERO_TICKER];
    [[NSUserDefaults standardUserDefaults] setBool:!zeroTickerOn forKey:USER_DEFAULTS_KEY_DEBUG_SIMULATE_ZERO_TICKER];
}

- (void)toggleCreateWalletPrefill
{
    DebugSettings *settings = DebugSettings.sharedInstance;
    settings.createWalletPrefill = !settings.createWalletPrefill;
}

- (void)toggleUseHomebrewForExchange
{
    DebugSettings *settings = DebugSettings.sharedInstance;
    settings.useHomebrewForExchange = !settings.useHomebrewForExchange;
}

- (void)mockExchangeOrderDepositAddress
{
    DebugSettings *settings = DebugSettings.sharedInstance;

    UIAlertController *depositAddressAlert = [UIAlertController alertControllerWithTitle:@"Mock deposit address" message:@"Type in the desired address to send exchange orders to." preferredStyle:UIAlertControllerStyleAlert];
    [depositAddressAlert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        BCSecureTextField *secureTextField = (BCSecureTextField *)textField;
        secureTextField.text = settings.mockExchangeOrderDepositAddress;
        secureTextField.returnKeyType = UIReturnKeyDone;
    }];
    [depositAddressAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        settings.mockExchangeOrderDepositAddress = [[depositAddressAlert textFields] firstObject].text;
    }]];
    [depositAddressAlert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
    [depositAddressAlert addAction:[UIAlertAction actionWithTitle:DEBUG_STRING_RESET style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        settings.mockExchangeOrderDepositAddress = nil;
    }]];
    [self presentViewController:depositAddressAlert animated:YES completion:nil];
}

- (void)toggleMockExchangeDeposit
{
    DebugSettings *settings = DebugSettings.sharedInstance;
    settings.mockExchangeDeposit = !settings.mockExchangeDeposit;
}

- (void)showFilteredWalletJSON
{
    UIViewController *viewController = [[UIViewController alloc] init];
    UITextView *walletJSONTextView = [[UITextView alloc] initWithFrame:viewController.view.frame];
    walletJSONTextView.text = [NSString stringWithFormat:@"%@", self.filteredWalletJSON];
    walletJSONTextView.editable = NO;
    [viewController.view addSubview:walletJSONTextView];
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return RowTotalCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;

    switch (indexPath.row) {
        case RowWalletJSON: {
            cell.textLabel.text = DEBUG_STRING_WALLET_JSON;
            cell.detailTextLabel.text = self.filteredWalletJSON == nil ? DEBUG_STRING_PLEASE_LOGIN : nil;
            cell.detailTextLabel.textColor = UIColor.red;
            cell.accessoryType = self.filteredWalletJSON == nil ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        case RowSurgeToggle: {
            cell.textLabel.text = DEBUG_STRING_SIMULATE_SURGE;
            UISwitch *surgeToggle = [[UISwitch alloc] init];
            BOOL surgeOn = [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_DEBUG_SIMULATE_SURGE];
            surgeToggle.on = surgeOn;
            [surgeToggle addTarget:self action:@selector(toggleSurge) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = surgeToggle;
            break;
        }
        case RowDontShowAgain: {
            cell.textLabel.text = DEBUG_STRING_RESET_DONT_SHOW_AGAIN_PROMPT;
            break;
        }
        case RowCertificatePinning: {
            cell.textLabel.text = DEBUG_STRING_CERTIFICATE_PINNING;
            UISwitch *pinningToggle = [[UISwitch alloc] init];
            BOOL pinningOn = [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_DEBUG_ENABLE_CERTIFICATE_PINNING];
            pinningToggle.on = pinningOn;
            [pinningToggle addTarget:self action:@selector(togglePinning) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = pinningToggle;
            break;
        }
        case RowSecurityReminderTimer: {
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.text = DEBUG_STRING_SECURITY_REMINDER_PROMPT_TIMER;
            break;
        }
        case RowZeroTickerValue: {
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.text = DEBUG_STRING_ZERO_VALUE_TICKER;
            UISwitch *zeroTickerToggle = [[UISwitch alloc] init];
            BOOL zeroTickerOn = [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_KEY_DEBUG_SIMULATE_ZERO_TICKER];
            zeroTickerToggle.on = zeroTickerOn;
            [zeroTickerToggle addTarget:self action:@selector(toggleZeroTicker) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = zeroTickerToggle;
            break;
        }
        case RowCreateWalletPrefill: {
            cell.textLabel.text = @"Create wallet prefill";
            UISwitch *prefillToggle = [[UISwitch alloc] init];
            prefillToggle.on = DebugSettings.sharedInstance.createWalletPrefill;
            [prefillToggle addTarget:self action:@selector(toggleCreateWalletPrefill) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = prefillToggle;
            break;
        }
        case RowCreateWalletCustomEmail: {
            cell.textLabel.text = @"Create wallet custom email prefill";
            break;
        }
        case RowUseHomebrewForExchange: {
            cell.textLabel.text = @"Use homebrew for exchange";
            UISwitch *prefillToggle = [[UISwitch alloc] init];
            prefillToggle.on = DebugSettings.sharedInstance.useHomebrewForExchange;
            [prefillToggle addTarget:self action:@selector(toggleUseHomebrewForExchange) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = prefillToggle;
            break;
        }
        case RowMockExchangeOrderDepositAddress: {
            cell.textLabel.text = @"Mock Homebrew Exchange deposit address";
            break;
        }
        case RowMockExchangeDeposit: {
            cell.textLabel.text = @"Mock exchange deposit";
            UISwitch *mockToggle = [[UISwitch alloc] init];
            mockToggle.on = DebugSettings.sharedInstance.mockExchangeDeposit;
            [mockToggle addTarget:self action:@selector(toggleMockExchangeDeposit) forControlEvents:UIControlEventTouchUpInside];
            cell.accessoryView = mockToggle;
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.row) {
        case RowWalletJSON: {
            if (self.filteredWalletJSON) {
                [self showFilteredWalletJSON];
            }
            break;
        }
        case RowDontShowAgain: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:DEBUG_STRING_DEBUG message:DEBUG_STRING_RESET_DONT_SHOW_AGAIN_PROMPT_MESSAGE preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:DEBUG_STRING_RESET style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                BlockchainSettings.sharedAppInstance.hideTransferAllFundsAlert = NO;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:USER_DEFAULTS_KEY_HIDE_APP_REVIEW_PROMPT];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:USER_DEFAULTS_KEY_HIDE_WATCH_ONLY_RECEIVE_WARNING];
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:USER_DEFAULTS_KEY_HAS_SEEN_SURVEY_PROMPT];
                BlockchainSettings.sharedAppInstance.hasEndedFirstSession = NO;
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            break;
        }
        case RowSecurityReminderTimer: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:DEBUG_STRING_DEBUG message:DEBUG_STRING_SECURITY_REMINDER_PROMPT_TIMER preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_OK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[[alert textFields] firstObject].text intValue]] forKey:USER_DEFAULTS_KEY_DEBUG_SECURITY_REMINDER_CUSTOM_TIMER];
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
            [alert addAction:[UIAlertAction actionWithTitle:DEBUG_STRING_RESET style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:TIME_INTERVAL_SECURITY_REMINDER_PROMPT] forKey:USER_DEFAULTS_KEY_DEBUG_SECURITY_REMINDER_CUSTOM_TIMER];
            }]];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.keyboardType = UIKeyboardTypeNumberPad;
                
                id customTimeValue = [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_KEY_DEBUG_SECURITY_REMINDER_CUSTOM_TIMER];
                
                textField.text = [NSString stringWithFormat:@"%i", customTimeValue ? [customTimeValue intValue] : TIME_INTERVAL_SECURITY_REMINDER_PROMPT];
            }];
            [self presentViewController:alert animated:YES completion:nil];
            break;
        }
        case RowMockExchangeOrderDepositAddress: {
            [self mockExchangeOrderDepositAddress];
            break;
        }
        case RowCreateWalletCustomEmail: {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Custom Email Prefill" message:@"Use a custom email for create wallet prefill." preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"Set static email" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                BCSecureTextField *secureTextField = (BCSecureTextField *)[[alert textFields] firstObject];
                DebugSettings *settings = DebugSettings.sharedInstance;
                settings.createWalletEmailRandomSuffix = NO;
                settings.createWalletEmailPrefill = secureTextField.text;
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"Set email + timestamped suffix" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                BCSecureTextField *secureTextField = (BCSecureTextField *)[[alert textFields] firstObject];
                DebugSettings *settings = DebugSettings.sharedInstance;
                settings.createWalletEmailRandomSuffix = YES;
                settings.createWalletEmailPrefill = secureTextField.text;
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:BC_STRING_CANCEL style:UIAlertActionStyleCancel handler:nil]];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.keyboardType = UIKeyboardTypeDefault;

                DebugSettings *settings = DebugSettings.sharedInstance;
                NSString *currentCustomEmail = settings.createWalletEmailPrefill;

                textField.text = currentCustomEmail;
            }];
            [self presentViewController:alert animated:YES completion:nil];
            break;
        }
        default:
            break;
    }
}

@end
