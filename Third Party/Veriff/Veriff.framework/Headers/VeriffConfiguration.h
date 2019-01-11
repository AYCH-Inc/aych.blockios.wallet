//
//  VeriffConfiguration.h
//  VeriffFramework
//
//  Copyright © 2016 Veriff. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VeriffConfiguration;
typedef void(^VeriffConfigurationBlock)(VeriffConfiguration *_Nonnull configuration);

typedef NS_ENUM(NSUInteger, Mode) {
    SANDBOX = 0,
    PRODUCTION = 1,
    DEMOZ1 = 2,
};

@interface VeriffConfiguration : NSObject

@property (nonatomic, strong) NSString *_Nullable sessionUrl;
@property (nonatomic, assign) NSUInteger mode;
@property (nonatomic, strong) NSString *_Nullable sessionToken;

+ (instancetype _Nonnull)configureWithBlock:(VeriffConfigurationBlock _Nonnull)block;

@end
