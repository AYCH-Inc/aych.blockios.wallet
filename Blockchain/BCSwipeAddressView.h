//
//  BCSwipeAddressView.h
//  Blockchain
//
//  Created by kevinwu on 3/9/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BCSwipeAddressViewModel.h"

@interface BCSwipeAddressView : UIView
- (id)initWithFrame:(CGRect)frame viewModel:(BCSwipeAddressViewModel *)viewModel;
- (void)updateAddress:(NSString *)address;
+ (CGFloat)pageIndicatorYOrigin;
@end
