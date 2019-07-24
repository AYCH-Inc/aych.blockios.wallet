//
//  BCConfirmPaymentViewModel.h
//  Blockchain
//
//  Created by kevinwu on 8/29/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BCConfirmPaymentViewModel : NSObject

- (instancetype)initWithFrom:(NSString *)from
   destinationDisplayAddress:(NSString *_Nonnull)destinationDisplayAddress
       destinationRawAddress:(NSString *_Nonnull)destinationRawAddress
                      amount:(uint64_t)amount
                         fee:(uint64_t)fee
                       total:(uint64_t)total
                       surge:(BOOL)surgePresent;

- (instancetype)initWithTo:(NSString *)destinationDisplayAddress
     destinationRawAddress:(NSString *)destinationRawAddress
                 ethAmount:(NSString *)ethAmount
                    ethFee:(NSString *)ethFee
                  ethTotal:(NSString *)ethTotal
                fiatAmount:(NSString *)fiatAmount
                   fiatFee:(NSString *)fiatFee
                 fiatTotal:(NSString *)fiatTotal;

- (instancetype)initWithFrom:(NSString *)from
   destinationDisplayAddress:(NSString *_Nonnull)destinationDisplayAddress
       destinationRawAddress:(NSString *_Nonnull)destinationRawAddress
                   bchAmount:(uint64_t)amount
                         fee:(uint64_t)fee
                       total:(uint64_t)total
                       surge:(BOOL)surgePresent;

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
            descriptionTitle:(NSString * _Nullable)descriptionTitle;

@property (nonatomic) NSString *from;
@property (nonatomic) NSString *destinationDisplayAddress;
@property (nonatomic) NSString *destinationRawAddress;
@property (nonatomic) NSString *totalAmountText;
@property (nonatomic) NSString *fiatTotalAmountText;
@property (nonatomic) NSString *cryptoWithFiatAmountText;
@property (nonatomic) NSString *amountWithFiatFeeText;
@property (nonatomic) NSString *noteText;
@property (nonatomic) NSString *buttonTitle;
@property (nonatomic, strong) NSString *descriptionTitle;
@property (nonatomic) BOOL showDescription;
@property (nonatomic) BOOL surgeIsOccurring;
@property (nonatomic) BOOL showsFeeInformationButton;
@property (nonatomic) NSAttributedString *warningText;
@end
