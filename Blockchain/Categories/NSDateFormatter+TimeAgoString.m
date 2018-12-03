//
//  NSDateFormatter+TimeAgoString.m
//  Blockchain
//
//  Created by kevinwu on 2/10/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import "NSDateFormatter+TimeAgoString.h"
#import "Blockchain-Swift.h"

@implementation NSDateFormatter (TimeAgoString)

+ (NSDateFormatter *)longFormatter {
    static dispatch_once_t token = 0;
    static NSDateFormatter *formatter = nil;
    dispatch_once(&token, ^{
        formatter = [NSDateFormatter new];
        [formatter setDateFormat:@"MMMM d y"];
    });
    return formatter;
}

+ (NSString *)timeAgoStringFromDate:(NSDate *)date
{
    long long secondsAgo  = -round([date timeIntervalSinceNow]);
    
    if (secondsAgo <= 1) { // Just now
        return [LocalizationConstantsObjcBridge justNow];
    } else if (secondsAgo < 60) { // 0 - 59 seconds
        return [NSString stringWithFormat:[LocalizationConstantsObjcBridge secondsAgo], secondsAgo];
    } else if (secondsAgo / 60 == 1) { // 1 minute
        return [LocalizationConstantsObjcBridge oneMinuteAgo];
    } else if (secondsAgo < 60 * 60) {  // 1 to 59 minutes
        return [NSString stringWithFormat:[LocalizationConstantsObjcBridge minutesAgo], secondsAgo / 60];
    } else if (secondsAgo / 60 / 60 == 1) { // 1 hour ago
        return [LocalizationConstantsObjcBridge oneHourAgo];
    } else if ([[NSCalendar currentCalendar] respondsToSelector:@selector(isDateInToday:)] && secondsAgo < 60 * 60 * 24 && [[NSCalendar currentCalendar] isDateInToday:date]) { // 1 to 23 hours ago, but only if today
        return [NSString stringWithFormat:[LocalizationConstantsObjcBridge hoursAgo], secondsAgo / 60 / 60];
    } else if([[NSCalendar currentCalendar] respondsToSelector:@selector(isDateInYesterday:)] && [[NSCalendar currentCalendar] isDateInYesterday:date]) { // yesterday
        return [LocalizationConstantsObjcBridge yesterday];
    } else {
        return [[NSDateFormatter longFormatter] stringFromDate:date];
    }
}

@end
