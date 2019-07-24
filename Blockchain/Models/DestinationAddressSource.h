//
//  DestinationAddressSource.h
//  Blockchain
//
//  Created by kevinwu on 5/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

#ifndef DestinationAddressSource_h
#define DestinationAddressSource_h

typedef enum {
    DestinationAddressSourceNone,
    DestinationAddressSourceQR,
    DestinationAddressSourcePaste,
    DestinationAddressSourceURI,
    DestinationAddressSourceDropDown,
    DestinationAddressSourcePit,
} DestinationAddressSource;

#endif /* DestinationAddressSource_h */
