//
//  Screen.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 19/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import UIKit

public protocol ScreenNavigationButton {
    var content: Screen.NavigationBarContent? { get }
}

public struct Screen {
    
    public struct NavigationBarContent {
        let title: String?
        let image: UIImage?
        let accessibility: Accessibility?
        public init(title: String? = nil,
                    image: UIImage? = nil,
                    accessibility: Accessibility? = nil) {
            self.title = title
            self.image = image
            self.accessibility = accessibility
        }
    }
    
    // MARK: - The style of the navigation bar contents
    
    public enum Style {
    
        // MARK: - The bar style
        
        /// Describes the bar style
        public enum Bar {
            
            /// Light bar style - white background, black content
            case lightContent(ignoresStatusBar: Bool, background: UIColor)
            
            /// Dark bar style - black background, white content
            case darkContent(ignoresStatusBar: Bool, background: UIColor)
            
            /// Returns the tint color of the content - title, left / right buttons
            var contentColor: UIColor {
                switch self {
                case .lightContent:
                    return .white
                case .darkContent:
                    return .black
                }
            }
            
            /// The color of the navigation bar's background
            var backgroundColor: UIColor {
                switch self {
                case .darkContent(ignoresStatusBar: _, background: let color):
                    return color
                case .lightContent(ignoresStatusBar: _, background: let color):
                    return color
                }
            }
            
            /// Returns the status bar style
            var statusBarStyle: UIStatusBarStyle {
                switch self {
                case .lightContent:
                    return .lightContent
                case .darkContent:
                    return .default
                }
            }
            
            /// Ignores the status bar if marked as `true`
            var ignoresStatusBar: Bool {
                switch self {
                case .darkContent(ignoresStatusBar: let value, background: _):
                    return value
                case .lightContent(ignoresStatusBar: let value, background: _):
                    return value
                }
            }
        }
        
        // MARK: - Title view style
        
        /// The view that represents the title
        public enum TitleView {
            
            /// Textual view
            case text(value: String)
            
            /// Visual image based view. Only the width can be customized
            case image(name: String, width: CGFloat)
            
            /// No title view
            case none
        }
        
        // MARK: - Trailing button style
        
        /// Describes the trailing button style
        public enum TrailingButton: ScreenNavigationButton {
            
            /// No trailing button style
            case none
            
            /// Displayable content
            case content(NavigationBarContent)
            
            /// Processing by displaying an activity indicator
            case processing
            
            /// Returns the content of the button
            public var content: NavigationBarContent? {
                switch self {
                case .content(let content):
                    return content
                default:
                    return nil
                }
            }
        }
        
        // MARK: - The leading button style
        
        /// Describes the leading button style
        public enum LeadingButton: ScreenNavigationButton {
            
            /// No button
            case none
            
            /// Back button, pops the view controller
            case back
            
            /// Close button, dismisses the view controller
            case close
            
            /// Button with text
            case text(value: String)
            
            /// Returns the content of the button
            public var content: NavigationBarContent? {
                switch self {
                case .text(value: let text):
                    return NavigationBarContent(title: text)
                case .back, .close:
                    return NavigationBarContent(
                        image: UIImage(named: "back_icon"),
                        accessibility: .init(
                            id: .value(Accessibility.Identifier.NavigationBar.backButton)
                        )
                    )
                case .none:
                    return nil
                }
            }
        }
    }
}
