//
//  EtherTransaction.h
//  Blockchain
//
//  Created by kevinwu on 8/30/17.
//  Copyright © 2017 Blockchain Luxembourg S.A. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EtherTransaction : NSObject

+ (EtherTransaction *)fromJSONDict:(NSDictionary *)dict;
+ (NSString *)truncatedAmount:(NSString *)amountString;

@property (nonatomic, nullable) NSString *amount;
@property (nonatomic, nullable) NSString *amountTruncated;
@property (nonatomic, nullable) NSString *fee;
@property (nonatomic, nullable) NSString *from;
@property (nonatomic, nullable) NSString *to;
@property (nonatomic, nullable) NSString *myHash;
@property (nonatomic, nullable) NSString *note;
@property (nonatomic, nullable) NSString *txType;
@property (nonatomic) uint64_t time;
@property (nonatomic) NSUInteger confirmations;

@property (nonatomic, strong, nullable) NSMutableDictionary *fiatAmountsAtTime;

@end
