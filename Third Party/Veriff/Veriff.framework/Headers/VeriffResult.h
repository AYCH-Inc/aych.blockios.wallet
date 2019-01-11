//
//  VeriffError.h
//  Veriff
//
//  Copyright © 2017 Veriff. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VeriffConstant) {
    UNABLE_TO_ACCESS_CAMERA,
    UNABLE_TO_RECORD_AUDIO,
    STATUS_USER_CANCELED,
    STATUS_SUBMITTED,
    STATUS_OUT_OF_BUSINESS_HOURS,
    STATUS_ERROR_SESSION,
    STATUS_ERROR_NETWORK,
    STATUS_ERROR_NO_IDENTIFICATION_METHODS_AVAILABLE,
    STATUS_DONE,
    STATUS_VIDEO_CALL_ENDED, //TODO will be implemented in V2

    STATUS_ERROR_UNKNOWN
};

@interface VeriffResult : NSObject

@property (nonatomic, assign) VeriffConstant code;
@property (strong, nonatomic) NSString *resultDescription;

+ (instancetype)resultWithCode:(VeriffConstant)code description:(NSString *)description;

@end
