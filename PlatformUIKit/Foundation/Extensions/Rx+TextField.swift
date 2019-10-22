//
//  Rx+TextField.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 08/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxCocoa
import RxSwift

extension Reactive where Base: UITextField {
    /// Bindable for `isSecureTextEntry` property
    public var isSecureTextEntry: Binder<Bool> {
        return Binder(self.base) { textField, isSecureTextEntry in
            textField.isSecureTextEntry = isSecureTextEntry
        }
    }
    
    /// Bindable for `textContentType` property
    public var contentType: Binder<UITextContentType?> {
        return Binder(self.base) { textField, contentType in
            textField.textContentType = contentType
        }
    }
    
    /// Bindable for `placeholderAttributedText` property
    public var placeholderAttributedText: Binder<NSAttributedString?> {
        return Binder(self.base) { textField, placeholder in
            textField.attributedPlaceholder = placeholder
        }
    }
    
    /// Bindable for `textColor` property
    public var textColor: Binder<UIColor> {
        return Binder(self.base) { textField, textColor in
            textField.textColor = textColor
        }
    }
}

