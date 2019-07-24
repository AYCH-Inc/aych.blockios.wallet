//
//  BCConfirmPaymentViewModel.m
//  Blockchain
//
//  Created by kevinwu on 8/29/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCConfirmPaymentViewModel.h"
#import "NSNumberFormatter+Currencies.h"
#import "Blockchain-Swift.h"

@interface BCConfirmPaymentViewModel ()
@end
@implementation BCConfirmPaymentViewModel

- (instancetype)initWithFrom:(NSString *)from
   destinationDisplayAddress:(NSString *_Nonnull)destinationDisplayAddress
       destinationRawAddress:(NSString *_Nonnull)destinationRawAddress
                      amount:(uint64_t)amount
                         fee:(uint64_t)fee
                       total:(uint64_t)total
                       surge:(BOOL)surgePresent
{
    self = [super init];
    
    if (self) {
        self.from = from;
        self.destinationDisplayAddress = destinationDisplayAddress;
        self.destinationRawAddress = destinationRawAddress;
        self.surgeIsOccurring = surgePresent;
        self.buttonTitle = BC_STRING_SEND;
        self.fiatTotalAmountText = [NSNumberFormatter formatMoney:total localCurrency:YES];
        self.totalAmountText = [NSNumberFormatter formatBTC:total];
        self.cryptoWithFiatAmountText = [self formatAmountInBTCAndFiat:amount];
        self.amountWithFiatFeeText = [self formatAmountInBTCAndFiat:fee];
        self.showDescription = YES;
        self.showsFeeInformationButton = YES;
    }
    return self;
}

- (instancetype)initWithTo:(NSString *)destinationDisplayAddress
     destinationRawAddress:(NSString *)destinationRawAddress
                 ethAmount:(NSString *)ethAmount
                    ethFee:(NSString *)ethFee
                  ethTotal:(NSString *)ethTotal
                fiatAmount:(NSString *)fiatAmount
                   fiatFee:(NSString *)fiatFee
                 fiatTotal:(NSString *)fiatTotal
{
    if (self == [super init]) {
        self.from = [LocalizationConstantsObjcBridge myEtherWallet];
        self.destinationDisplayAddress = destinationDisplayAddress;
        self.destinationRawAddress = destinationRawAddress;
        self.fiatTotalAmountText = fiatTotal;
        self.totalAmountText = ethTotal;
        self.cryptoWithFiatAmountText = [NSString stringWithFormat:@"%@ (%@)", ethAmount, fiatAmount];
        self.amountWithFiatFeeText = [NSString stringWithFormat:@"%@ (%@)", ethFee, fiatFee];
        self.showDescription = YES;
        self.showsFeeInformationButton = YES;
    }
    return self;
}

- (instancetype)initWithFrom:(NSString *)from
   destinationDisplayAddress:(NSString *_Nonnull)destinationDisplayAddress
       destinationRawAddress:(NSString *_Nonnull)destinationRawAddress
                   bchAmount:(uint64_t)amount
                         fee:(uint64_t)fee
                       total:(uint64_t)total
                       surge:(BOOL)surgePresent
{
    self = [super init];
    
    if (self) {
        self.from = from;
        self.destinationDisplayAddress = destinationDisplayAddress;
        self.destinationRawAddress = destinationRawAddress;
        self.surgeIsOccurring = surgePresent;
        self.fiatTotalAmountText = [NSNumberFormatter formatBchWithSymbol:total localCurrency:YES];
        self.totalAmountText = [NSNumberFormatter formatBCH:total];
        self.cryptoWithFiatAmountText = [self formatAmountInBCHAndFiat:amount];
        self.amountWithFiatFeeText = [self formatAmountInBCHAndFiat:fee];
        self.showDescription = YES;
        self.showsFeeInformationButton = YES;
        
        if ([WalletManager.sharedInstance.wallet isValidAddress:self.destinationRawAddress assetType:LegacyAssetTypeBitcoin]) {
            CGFloat fontSize = FONT_SIZE_EXTRA_SMALL;
            NSMutableAttributedString *warning = [[NSMutableAttributedString alloc] initWithString:BC_STRING_BITCOIN_CASH_WARNING_CONFIRM_VALID_ADDRESS_ONE];
            [warning addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_MONTSERRAT_REGULAR size:fontSize] range:NSMakeRange(0, [warning length])];
            
            NSMutableAttributedString *warningSuffix = [[NSMutableAttributedString alloc] initWithString:BC_STRING_BITCOIN_CASH_WARNING_CONFIRM_VALID_ADDRESS_TWO];
            
            [warningSuffix addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_MONTSERRAT_LIGHT size:fontSize] range:NSMakeRange(0, [warningSuffix length])];
            
            [warning appendAttributedString:[[NSAttributedString alloc] initWithString:@" "]];
            [warning appendAttributedString:warningSuffix];
            
            self.warningText = warning;
        }
    }
    return self;
}

- (instancetype)initWithFrom:(NSString *_Nonnull)from
   destinationDisplayAddress:(NSString *_Nonnull)destinationDisplayAddress
       destinationRawAddress:(NSString *_Nonnull)destinationRawAddress
             totalAmountText:(NSString *_Nonnull)totalAmountText
         fiatTotalAmountText:(NSString *_Nonnull)fiatTotalAmountText
    cryptoWithFiatAmountText:(NSString *_Nonnull)cryptoWithFiatAmountText
       amountWithFiatFeeText:(NSString *_Nonnull)amountWithFiatFeeText
                 buttonTitle:(NSString *_Nonnull)buttonTitle
             showDescription:(BOOL)showDescription
            surgeIsOccurring:(BOOL)surgeIsOccurring
          showsFeeInformationButton:(BOOL)showsFeeInformationButton
                    noteText:(NSString *_Nullable)noteText
                 warningText:(NSAttributedString *_Nullable)warningText
            descriptionTitle:(NSString * _Nullable)descriptionTitle
{
    self = [super init];
    if (self) {
        self.from = from;
        self.destinationDisplayAddress = destinationDisplayAddress;
        self.destinationRawAddress = destinationRawAddress;
        self.totalAmountText = totalAmountText;
        self.fiatTotalAmountText = fiatTotalAmountText;
        self.cryptoWithFiatAmountText = cryptoWithFiatAmountText;
        self.amountWithFiatFeeText = amountWithFiatFeeText;
        self.buttonTitle = buttonTitle;
        self.showDescription = showDescription;
        self.surgeIsOccurring = surgeIsOccurring;
        self.showsFeeInformationButton = showsFeeInformationButton;
        self.noteText = noteText;
        self.warningText = warningText;
        self.descriptionTitle = descriptionTitle;
    }
    return self;
}

#pragma mark - Text Helpers

- (NSString *)formatAmountInBTCAndFiat:(uint64_t)amount
{
    return [NSString stringWithFormat:@"%@ (%@)", [NSNumberFormatter formatMoney:amount localCurrency:NO], [NSNumberFormatter formatMoney:amount localCurrency:YES]];
}

- (NSString *)formatAmountInBCHAndFiat:(uint64_t)amount
{
    return [NSString stringWithFormat:@"%@ (%@)", [NSNumberFormatter formatBchWithSymbol:amount localCurrency:NO], [NSNumberFormatter formatBchWithSymbol:amount localCurrency:YES]];
}

@end
