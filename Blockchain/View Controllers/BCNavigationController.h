//
//  BCNavigationController.h
//  Blockchain
//
//  Created by Kevin Wu on 10/12/16.
//  Copyright © 2016 Blockchain Luxembourg S.A. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BCNavigationController : UINavigationController
@property (nonatomic) UIView *topBar;
@property (nonatomic) UIButton *backButton;
@property (nonatomic) UIButton *closeButton;
@property (nonatomic) UILabel *headerLabel;
@property (nonatomic) NSString *headerTitle;
@property (nonatomic) UIButton *topRightButton;

@property (nonatomic) BOOL shouldHideBusyView;

@property(nonatomic, copy) void (^onPopViewController)(void);
@property(nonatomic, copy) void (^onViewWillDisappear)(void);

// A light appearance will have dark (dark blue) text.
// A dark appearance will have light (white) text.
typedef enum {
    NavigationBarAppearanceLight,
    NavigationBarAppearanceDark
} NavigationBarAppearance;

// Use an appearance that describes the backgroundColor
// in order to get a text color that is easily readable.
// If the backgroundColor is dark, use NavigationBarAppearanceDark.
// If the backgroundColor is light, use NavigationBarAppearanceLight.
- (void)applyNavigationBarAppearance:(NavigationBarAppearance)appearance withBackgroundColor:(UIColor *)backgroundColor;

- (_Nonnull id)initWithRootViewController:(UIViewController *)rootViewController title:(NSString *)title;

@end
