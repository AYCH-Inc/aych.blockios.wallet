//
//  DigitPadButtonViewModel.swift
//  Blockchain
//
//  Created by Daniel Huri on 07/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxCocoa
import RxSwift

struct DigitPadButtonViewModel {
    
    // MARK: - Internal Types
    
    enum Content {
        enum Image {
            case touchId
            case faceId
            case backspace
            
            /// The computed image value corresponding to `self`.
            var image: UIImage {
                let name: String
                switch self {
                case .backspace:
                    name = "back_icon"
                case .faceId:
                    name = "face_id_icon"
                case .touchId:
                    name = "touch_id_icon"
                }
                return UIImage(named: name)!.withRenderingMode(.alwaysTemplate)
            }
            
            /// Accessibility id for image
            var accessibility: Accessibility {
                let accessibility: Accessibility
                switch self {
                case .backspace:
                    accessibility = Accessibility(id: .value(AccessibilityIdentifiers.PinScreen.backspaceButton),
                                                  label: .value(LocalizationConstants.Pin.Accessibility.backspace))
                case .faceId:
                    accessibility = Accessibility(id: .value(AccessibilityIdentifiers.PinScreen.faceIdButton),
                                                  label: .value(LocalizationConstants.Pin.Accessibility.faceId))
                case .touchId:
                    accessibility = Accessibility(id: .value(AccessibilityIdentifiers.PinScreen.touchIdButton),
                                                  label: .value(LocalizationConstants.Pin.Accessibility.touchId))
                }
                return accessibility
            }
        }
        
        /// Image based button
        case image(type: Image, tint: UIColor)
        
        /// Text based button
        case label(text: String, tint: UIColor)
        
        /// Just an empty content
        case none
        
        /// Tint of the content
        var tint: UIColor {
            switch self {
            case .image(type: _, tint: let color):
                return color
            case .label(text: _, tint: let color):
                return color
            case .none:
                return .clear
            }
        }
        
        /// Accessibility for any nested value
        var accessibility: Accessibility {
            switch self {
            case .image(type: let image, tint: _):
                return image.accessibility
            case .label(text: let value, tint: _):
                return Accessibility(id: .value("\(AccessibilityIdentifiers.PinScreen.digitButtonFormat)\(value)"))
            case .none:
                return .none
            }
        }
    }
    
    struct Background {
        let cornerRadius: CGFloat
        let highlightColor: UIColor
        
        /// Just a clear background
        static var clear: Background {
            return Background(cornerRadius: 0, highlightColor: .clear)
        }
        
        init(cornerRadius: CGFloat = 4, highlightColor: UIColor) {
            self.cornerRadius = cornerRadius
            self.highlightColor = highlightColor
        }
    }
    
    static var empty: DigitPadButtonViewModel {
        return DigitPadButtonViewModel(content: .none, background: .clear)
    }
    
    // MARK: - Properties
    
    let content: Content
    let background: Background
    
    private let tapRelay = PublishRelay<Content>()
    var tapObservable: Observable<Content> {
        return tapRelay.asObservable()
    }
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(content: Content, background: Background) {
        self.content = content
        self.background = background
        tapRelay.bind { _ in
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
        }.disposed(by: disposeBag)
    }
    
    /// Invocation makes `tapRelay` to stream a new value
    func tap() {
        tapRelay.accept(content)
    }
}
