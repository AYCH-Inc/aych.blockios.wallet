//
//  NoticeViewModel.swift
//  Blockchain
//
//  Created by Daniel Huri on 28/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

public struct NoticeViewModel: Equatable {
    
    /// The image name
    let image: String
    
    /// The label content
    let labelContent: LabelContent
    
    public init(image: String, labelContent: LabelContent) {
        self.image = image
        self.labelContent = labelContent
    }
}
