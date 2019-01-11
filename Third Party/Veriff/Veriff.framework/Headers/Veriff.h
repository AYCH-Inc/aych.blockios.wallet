//
//  Veriff.h
//  VeriffFramework
//
//  Copyright © 2016 Veriff. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "VeriffConfiguration.h"
#import "VeriffResult.h"
#import "ColorSchema.h"

#if DEBUG
#define MSLog(s, ...) NSLog( @"<%p %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define MSLog(s, ...) //
#endif

#define VLocalizedString(key, comment) [[NSBundle bundleForClass:self.class] localizedStringForKey:(key) value:@"" table:nil]

#define kSessionUrl @"kSessionUrl"
#define kSessionToken @"kSessionToken"
#define kCameraButtonColor @"kCameraButtonColor"

typedef void (^NetworkProcessBlock)(VeriffResult * _Nonnull result);
typedef void (^ProcessBlock)(NSString * _Nonnull sessionUrl, VeriffResult * _Nonnull result);
typedef void (^ProcessErrorBlock)(NSError * _Nonnull error);

typedef void (^AuthCompletionBlock)(UIViewController * _Nonnull viewController);
typedef void (^FailureBlock)(NSError * _Nonnull error);

@interface Veriff : NSObject

+ (void)configureWithBlock:(VeriffConfigurationBlock _Nonnull )block;
+ (void)createColorSchemaWithBlock:(VeriffColorSchemaBlock _Nonnull)block;
+ (instancetype _Nonnull)sharedInstance;

- (void)requestViewControllerWithCompletion:(_Nonnull AuthCompletionBlock)completion;

- (void)setResultBlock:(ProcessBlock _Nonnull )result;

+ (void)setBackgroundImage:(NSString *_Nonnull)imageUrlString;
+ (void)setFirebaseDeviceToken:(NSString *_Nonnull)deviceToken __deprecated_msg("Push notifications are not supported anymore");
+ (void)processPushNotification:(NSDictionary *_Nonnull)userData __deprecated_msg("Push notifications are not supported anymore");

@end
