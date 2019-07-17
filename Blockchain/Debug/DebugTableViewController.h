//
//  DebugTableViewController.h
//  Blockchain
//
//  Created by Kevin Wu on 12/29/15.
//  Copyright © 2015 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DebugViewPresenter) {
    welcome = 0,
    pin = 2,
    settings = 3
};

@interface DebugTableViewController : UITableViewController
@property (nonatomic, assign) DebugViewPresenter presenter;
@end
