//
//  AssetSelectorView.m
//  Blockchain
//
//  Created by kevinwu on 2/14/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import "AssetSelectorView.h"
#import "UIView+ChangeFrameAttribute.h"
#import "Blockchain-Swift.h"

#define CELL_IDENTIFIER_ASSET_SELECTOR @"assetSelectorCell"

@interface AssetSelectorView () <UITableViewDataSource, UITableViewDelegate, AssetTypeCellDelegate>
@property (nonatomic) UITableView *tableView;
@property (nonatomic, readwrite) BOOL isOpen;
@property (nonatomic, readwrite) NSArray *assets;

@property (nonatomic, strong) NSLayoutConstraint *heightConstraint;

@end

@implementation AssetSelectorView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupInParent:nil];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame parentView:(UIView *)parentView
{
    if (self == [super initWithFrame:frame]) {
        [self setupInParent: parentView];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame assets:(NSArray *)assets parentView:(UIView *)parentView
{
    AssetSelectorView *assetSelectorView = [self initWithFrame:frame parentView:parentView];
    assetSelectorView.assets = assets;
    return assetSelectorView;
}

- (void)setupInParent:(UIView *)parentView
{
    if (self.tableView == nil) {
        NSMutableArray *allAssets = [
                                     @[[NSNumber numberWithInteger:LegacyAssetTypeBitcoin],
                                       [NSNumber numberWithInteger:LegacyAssetTypeEther],
                                       [NSNumber numberWithInteger:LegacyAssetTypeBitcoinCash]] mutableCopy];
        if ([AppFeatureConfigurator.sharedInstance configurationFor:AppFeatureStellar].isEnabled) {
            [allAssets addObject:[NSNumber numberWithInteger:LegacyAssetTypeStellar]];
        }
        [allAssets addObject:[NSNumber numberWithInteger:LegacyAssetTypePax]];
        self.assets = [allAssets copy];
        
        self.clipsToBounds = YES;
        
        self.tableView = [[UITableView alloc] initWithFrame:self.bounds];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.tableView registerNib:[UINib nibWithNibName:@"AssetTypeCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[AssetTypeCell identifier]];
        [self addSubview:self.tableView];
        
        self.tableView.separatorColor = [UIColor darkBlue];
        self.tableView.backgroundColor = [UIColor darkBlue];
        self.backgroundColor = [UIColor darkBlue];
                
        self.tableView.translatesAutoresizingMaskIntoConstraints = false;

        CGFloat height = [ConstantsObjcBridge assetTypeCellHeight] * self.assets.count;
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:height];
        [self.tableView addConstraint:heightConstraint];
        
        [NSLayoutConstraint activateConstraints: @[
            [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
            [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0],
            [NSLayoutConstraint constraintWithItem:self.tableView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0]
        ]];
                        
        if (parentView != nil) {
            [self constraintToParent:parentView];
        }
    }
}

- (void)constraintToParent:(UIView *)parentView {
    self.translatesAutoresizingMaskIntoConstraints = false;
        
    if (self.superview == nil) {
        [parentView addSubview:self];
    }
    
    [NSLayoutConstraint activateConstraints: @[
        [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeRight multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:parentView attribute:NSLayoutAttributeTop multiplier:1 constant:0]
    ]];
    
    CGFloat height = [ConstantsObjcBridge assetTypeCellHeight];
    self.heightConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:height];
    [self addConstraint: self.heightConstraint];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LegacyAssetType legacyAsset = self.isOpen ? [self.assets[indexPath.row] integerValue] : self.selectedAsset;
    BOOL showChevron = indexPath.row == 0;
    AssetType asset = [AssetTypeLegacyHelper convertFromLegacy:legacyAsset];

    AssetTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:[AssetTypeCell identifier] forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsMake(0.0, cell.bounds.size.width, 0.0, 0.0);
    [cell configureWith:asset showChevronButton:showChevron];
    cell.delegate = self;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.isOpen ? self.assets.count : 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isOpen) {
        AssetTypeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        self.selectedAsset = cell.legacyAssetType;
        [self.delegate didSelectAsset:cell.legacyAssetType];
        [self close];
    } else {
        [self open];
        [self.delegate didOpenSelector];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [ConstantsObjcBridge assetTypeCellHeight];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    AssetTypeCell *assetTypeCell = (AssetTypeCell *)cell;
    Direction direction = self.isOpen ? DirectionUp : DirectionDown;
    [assetTypeCell pointChevronButton:direction];
}

- (void)hide
{
    [self.superview layoutIfNeeded];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.heightConstraint.constant = 0;
        [self.superview layoutIfNeeded];
    }];
}

- (void)show
{
    [self.superview layoutIfNeeded];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.heightConstraint.constant = [ConstantsObjcBridge assetTypeCellHeight];
        [self.superview layoutIfNeeded];
    }];
}

- (void)open
{
    [self reportOpen];
    
    self.isOpen = YES;

    [self.tableView reloadData];
    [self.superview layoutIfNeeded];
    [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.heightConstraint.constant = [ConstantsObjcBridge assetTypeCellHeight] * self.assets.count;
        [self.superview layoutIfNeeded];
    } completion:nil];
}

- (void)close
{
    if (self.isOpen) {
        
        [self reportClose];
    
        self.isOpen = NO;
        
        [self.tableView reloadData];
        [self.superview layoutIfNeeded];
        [UIView animateWithDuration:ANIMATION_DURATION delay:0 options:UIViewAnimationOptionLayoutSubviews animations:^{
            self.heightConstraint.constant = [ConstantsObjcBridge assetTypeCellHeight];
            [self.superview layoutIfNeeded];
        } completion:nil];
    }
}

- (void)reload
{
    [self.tableView reloadData];
}

#pragma mark - AssetTypeCellDelegate

- (void)didTapChevronButton
{
    if (self.isOpen) {
        [self.delegate didSelectAsset:self.selectedAsset];
        [self close];
    } else {
        [self open];
        [self.delegate didOpenSelector];
    }
}

@end
