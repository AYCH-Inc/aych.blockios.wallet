//
//  BCSwipeAddressViewModel.m
//  Blockchain
//
//  Created by kevinwu on 3/12/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import "BCSwipeAddressViewModel.h"

@implementation BCSwipeAddressViewModel

- (id)initWithAssetType:(AssetType)assetType address:(NSString *)address
{
    if (self == [super init]) {
        self.address = address;
        NSString *suffix;
        NSString *assetImageViewName;
        if (assetType == AssetTypeBitcoin) {
            suffix = BC_STRING_BITCOIN;
            assetImageViewName = @"bitcoin";
        } else if (assetType == AssetTypeEther) {
            suffix = BC_STRING_ETHER;
            assetImageViewName = @"ether";
        } else if (assetType == AssetTypeBitcoinCash) {
            suffix = BC_STRING_BITCOIN_CASH;
            assetImageViewName = @"bitcoin_cash";
        }
        self.action = [[[BC_STRING_REQUEST stringByAppendingString:@" "] stringByAppendingString:suffix] uppercaseString];
    }
    return self;
}

@end
