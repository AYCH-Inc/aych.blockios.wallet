//
//  ColorSchema.h
//  Veriff
//
//  Copyright © 2017 Veriff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class ColorSchema;
typedef void(^VeriffColorSchemaBlock)(ColorSchema *_Nonnull schema);

@interface ColorSchema : NSObject<NSCoding>

@property (strong, nonatomic) UIColor *_Nullable backgroundColor;
@property (strong, nonatomic) UIColor *_Nullable footerColor;
@property (strong, nonatomic) UIColor *_Nullable controlsColor;
@property (strong, nonatomic) UIColor *_Nullable cameraControlsColor;
@property (strong, nonatomic) UIColor *_Nullable hintFooterColor;

+ (instancetype _Nonnull)configureWithBlock:(VeriffColorSchemaBlock _Nonnull)block;

@end
