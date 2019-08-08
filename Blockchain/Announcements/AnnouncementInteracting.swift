//
//  AnnouncementInteracting.swift
//  Blockchain
//
//  Created by Daniel Huri on 26/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

// TODO: Create mock for this to be able to test the presenting layer
protocol AnnouncementInteracting {
    var preliminaryData: Single<AnnouncementPreliminaryData> { get }
}
