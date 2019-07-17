//
//  TransactionDetailViewController.h
//  Blockchain
//
//  Created by Kevin Wu on 8/23/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TransactionDetailViewModel.h"

@interface TransactionDetailViewController : UIViewController

@property (nonatomic) TransactionDetailViewModel *transactionModel;
@property (nonatomic, readonly) BOOL didSetTextViewCursorPosition;

- (void)reloadSymbols;
- (void)didGetHistory;

@end
