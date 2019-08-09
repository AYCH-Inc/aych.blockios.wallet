//
//  BCQRCodeView.h
//  Blockchain
//
//  Created by Kevin Wu on 1/29/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Assets.h"

@protocol DoneButtonDelegate
- (void)doneButtonClicked;
@end
@interface BCQRCodeView : UIView
@property (nonatomic) UIImageView *qrCodeImageView;
@property (nonatomic) NSString *address;
@property (nonatomic) UILabel *qrCodeFooterLabel;
@property (nonatomic) UILabel *qrCodeHeaderLabel;
@property (nonatomic) UIButton *doneButton;
@property (nonatomic) LegacyAssetType assetType;

@property (nonatomic) id<DoneButtonDelegate> doneButtonDelegate;

- (id)initWithFrame:(CGRect)frame qrHeaderText:(NSString *)qrHeaderText addAddressPrefix:(BOOL)addPrefix;
- (id)initWithFrame:(CGRect)frame qrHeaderText:(NSString *)qrHeaderText addAddressPrefix:(BOOL)addPrefix assetType:(LegacyAssetType)assetType;

@end
