//
//  UIFont+Utils.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 27/08/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import UIKit

extension UIFont {
    
    private enum InterType: String {
        case regular = "Inter-Regular"
        case medium = "Inter-Medium"
        case semiBold = "Inter-SemiBold"
        case bold = "Inter-Bold"
        
    }
    
    public static func mainMedium(_ size: CGFloat) -> UIFont {
        return UIFont(name: InterType.medium.rawValue, size: size)!
    }
    
    public static func mainRegular(_ size: CGFloat) -> UIFont {
        return UIFont(name: InterType.regular.rawValue, size: size)!
    }
    
    public static func mainSemibold(_ size: CGFloat) -> UIFont {
        return UIFont(name: InterType.semiBold.rawValue, size: size)!
    }
    
    public static func mainBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: InterType.bold.rawValue, size: size)!
    }
}
