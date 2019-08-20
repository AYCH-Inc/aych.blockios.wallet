//
//  HDKeyPath.swift
//  HDWalletKit
//
//  Created by Jack on 18/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import LibWally

public enum DerivationComponent: Equatable {
    case normal(UInt32)
    case hardened(UInt32)
    
    public var isHardened: Bool {
        switch self {
        case .normal:
            return false
        case .hardened:
            return true
        }
    }
    
    var libWallyComponent: BIP32Derivation {
        switch self {
        case .normal(let value):
            return .normal(value)
        case .hardened(let value):
            return .hardened(value)
        }
    }
}

extension BIP32Derivation {
    var component: DerivationComponent {
        switch self {
        case .normal(let value):
            return .normal(value)
        case .hardened(let value):
            return .hardened(value)
        }
    }
}

extension BIP32Path {
    var derivationComponents: [DerivationComponent] {
        return components.map { $0.component }
    }
}

public struct HDKeyPath: LosslessStringConvertible {
    
    public var description: String {
        return libWallyPath.description
    }
    
    public let components: [DerivationComponent]
    
    internal let libWallyPath: BIP32Path
    
    public init(_ component: DerivationComponent, relative: Bool = true) throws {
        try self.init([component], relative: relative)
    }
    
    public init(_ index: Int, relative: Bool = true) throws {
        try self.init([.normal(UInt32(index))], relative: relative)
    }
    
    public init(_ components: [DerivationComponent], relative: Bool) throws {
        let libWallyComponents = components.map { $0.libWallyComponent }
        
        let libWallyPath: BIP32Path
        do {
            libWallyPath = try BIP32Path(libWallyComponents, relative: relative)
        } catch {
            throw HDWalletKitError.libWallyError(error)
        }
        
        self.libWallyPath = libWallyPath
        self.components = libWallyPath.derivationComponents
    }
    
    public init?(_ description: String) {
        guard let libWallyPath = BIP32Path(description) else { return nil }
        self.components = libWallyPath.derivationComponents
        self.libWallyPath = libWallyPath
    }
    
}
