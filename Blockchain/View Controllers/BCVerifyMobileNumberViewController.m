//
//  BCVerifyMobileNumberViewController.m
//  Blockchain
//
//  Created by kevinwu on 2/14/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCVerifyMobileNumberViewController.h"
#import "Blockchain-Swift.h"

@interface BCVerifyMobileNumberViewController () <UITextFieldDelegate>
@property (nonatomic) BCSecureTextField *mobileNumberField;
@property (nonatomic) UILabel *verifiedStatusLabel;
@property (nonatomic) UIButton *updateButton;
@end

@implementation BCVerifyMobileNumberViewController

- (id)initWithMobileDelegate:(UIViewController<MobileNumberDelegate>*)delegate
{
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (void)loadView
{
    self.view = [[UIView alloc] initWithFrame:self.delegate.view.frame];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (self.view == nil) {
        [super loadView];
    }
    
    CGFloat promptFrameAdjustY = 0;
    CGFloat textFieldFrameAdjustY = 0;
    
    if (!(IS_USING_SCREEN_SIZE_4S)) {
        promptFrameAdjustY = 8;
        textFieldFrameAdjustY = 20;
    }
    
    UILabel *promptLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, DEFAULT_HEADER_HEIGHT + 16 + promptFrameAdjustY, self.view.frame.size.width - 80, 140)];
    promptLabel.numberOfLines = 7;
    promptLabel.textAlignment = NSTextAlignmentCenter;
    promptLabel.font = [UIFont fontWithName:FONT_GILL_SANS_REGULAR size:FONT_SIZE_MEDIUM];
    promptLabel.text = BC_STRING_SETTINGS_SMS_PROMPT;
    promptLabel.textColor = UIColor.gray5;
    [self.view addSubview:promptLabel];
    
    [promptLabel sizeToFit];
    
    promptLabel.center = CGPointMake(self.view.center.x, promptLabel.center.y);
    
    self.mobileNumberField = [[BCSecureTextField alloc] initWithFrame:CGRectMake(0, promptLabel.frame.origin.y + promptLabel.frame.size.height + 16 + textFieldFrameAdjustY, promptLabel.frame.size.width, 26)];
    self.mobileNumberField.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_EXTRA_LARGE];
    self.mobileNumberField.textColor = UIColor.gray5;
    self.mobileNumberField.placeholder = BC_STRING_SETTINGS_MOBILE_NUMBER;
    self.mobileNumberField.keyboardType = UIKeyboardTypePhonePad;
    self.mobileNumberField.textAlignment = NSTextAlignmentCenter;
    self.mobileNumberField.delegate = self;
    [self.view addSubview:self.mobileNumberField];
    self.mobileNumberField.center = CGPointMake(self.view.center.x, self.mobileNumberField.center.y);
    
    UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    updateButton.frame = CGRectMake(0, 0, self.view.frame.size.width, 46);
    updateButton.backgroundColor = UIColor.brandSecondary;
    [updateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    updateButton.titleLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:FONT_SIZE_LARGE];
    [updateButton setTitle:BC_STRING_UPDATE forState:UIControlStateNormal];
    [updateButton addTarget:self action:@selector(updateButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    self.updateButton = updateButton;
    
    self.mobileNumberField.inputAccessoryView = updateButton;
    
    self.verifiedStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.mobileNumberField.frame.origin.y + self.mobileNumberField.frame.size.height + 8, 150, 26)];
    self.verifiedStatusLabel.textAlignment = NSTextAlignmentCenter;
    self.verifiedStatusLabel.font = [UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:FONT_SIZE_MEDIUM];
    [self.view addSubview:self.verifiedStatusLabel];
    self.verifiedStatusLabel.center = CGPointMake(self.view.center.x, self.verifiedStatusLabel.center.y);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reload];
    
    SettingsNavigationController *navigationController = (SettingsNavigationController *)self.navigationController;
    navigationController.headerLabel.text = BC_STRING_SETTINGS_MOBILE_NUMBER;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![self.delegate verifyMobileNumberViewControllerShowVerifyAlertIfNeeded:self]) {
        [self.mobileNumberField becomeFirstResponder];
    }
}

- (void)reload
{
    NSString *mobileNumber = [self getMobileNumber];
    
    self.mobileNumberField.text = self.mobileNumberField.text.length > 0 && [mobileNumber isEqualToString:@""] ? self.mobileNumberField.text : mobileNumber;
    
    if ([self getVerifiedStatus]) {
        self.verifiedStatusLabel.textColor = UIColor.green;
        self.verifiedStatusLabel.text = BC_STRING_SETTINGS_VERIFIED;
    } else {
        self.verifiedStatusLabel.textColor = UIColor.error;
        self.verifiedStatusLabel.text = BC_STRING_SETTINGS_UNVERIFIED;
    }
}

#pragma mark - Actions

- (NSString *)getMobileNumber
{
    return [self.delegate getMobileNumber];
}

- (BOOL)getVerifiedStatus
{
    return [self.delegate isMobileVerified];
}

- (void)updateButtonClicked
{
    [self reportUpdateButtonPressed];
    [self.mobileNumberField resignFirstResponder];
    
    [self performSelector:@selector(changeMobileNumber) withObject:nil afterDelay:DELAY_KEYBOARD_DISMISSAL];
}

- (void)changeMobileNumber
{
    [self.delegate verifyMobileNumberViewController:self changeMobileNumber:self.mobileNumberField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self updateButtonClicked];
    return YES;
}

@end
