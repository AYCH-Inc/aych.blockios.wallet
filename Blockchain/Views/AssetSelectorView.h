//
//  AssetSelectorView.h
//  Blockchain
//
//  Created by kevinwu on 2/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Assets.h"

@protocol AssetSelectorViewDelegate
- (void)didSelectAsset:(LegacyAssetType)assetType;
- (void)didOpenSelector;
@end
@interface AssetSelectorView : UIView
@property (nonatomic) LegacyAssetType selectedAsset;
@property (nonatomic, readonly) NSArray *assets;
@property (nonatomic, readonly) BOOL isOpen;
@property (nonatomic, weak) id <AssetSelectorViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame assets:(NSArray *)assets;
- (void)close;
- (void)open;
- (void)hide;
- (void)show;
- (void)reload;
@end
