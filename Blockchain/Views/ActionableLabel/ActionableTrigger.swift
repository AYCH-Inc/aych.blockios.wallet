//
//  ActionableTrigger.swift
//  Blockchain
//
//  Created by Alex McGregor on 10/24/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

public struct ActionableTrigger: Equatable {
    public let primaryString: String
    public let callToAction: String
    public let execute: (() -> Void)
    
    public init(text: String, CTA: String, executionBlock: @escaping (() -> Void)) {
        self.primaryString = text
        self.callToAction = CTA
        self.execute = executionBlock
    }
}

public extension ActionableTrigger {
    public static func == (lhs: ActionableTrigger, rhs: ActionableTrigger) -> Bool {
        return lhs.primaryString == rhs.primaryString &&
            lhs.callToAction == rhs.callToAction
    }
}

extension ActionableTrigger {
    public func actionRange() -> NSRange? {
        let text = primaryString + " " + callToAction
        let value = NSString(string: text)
        return value.range(of: callToAction)
    }
}
