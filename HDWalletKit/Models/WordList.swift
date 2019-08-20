//
//  WordList.swift
//  HDWalletKit
//
//  Created by Jack on 15/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import LibWally

public struct WordList {
    
    private struct Languages {
        // TODO:
        // * Check this is the correct wordlist
        public static let english = WordList(words: BIP39Words)
    }
    
    public static let `default` = Languages.english
    
    public let words: [String]
    
    private init(words: [String]) {
        self.words = words
    }
    
}
