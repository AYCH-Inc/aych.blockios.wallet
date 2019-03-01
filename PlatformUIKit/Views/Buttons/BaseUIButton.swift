//
//  BaseUIButton.swift
//  PlatformUIKit
//
//  Created by AlexM on 2/25/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@IBDesignable
public class BaseUIButton: UIButton {
    
    @IBInspectable public var showShadow: Bool = false {
        didSet {
            setup()
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 0.0 {
        didSet {
            setupLayout()
        }
    }
    
    public var shadowColor: UIColor = .black {
        didSet {
            setup()
        }
    }
    
    public var shadowOpacity: CGFloat = 0.20 {
        didSet {
            self.setup()
        }
    }
    
    func setup() {
        titleLabel?.font = Font(.branded(.montserratSemiBold), size: .custom(20.0)).result
        
        if showShadow {
            layer.shadowColor = self.shadowColor.cgColor
            layer.shadowOffset = CGSize(width: 0.0, height: 8.0)
            layer.shadowRadius = 8.0
            layer.shadowOpacity = Float(shadowOpacity)
            clipsToBounds = false
            layer.masksToBounds = false
        }
    }
    
    func setupLayout() {
        layer.cornerRadius = cornerRadius
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupLayout()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Overrides
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        setupLayout()
    }
}

@IBDesignable
public class BaseUIButtonFill: BaseUIButton {
    
    @IBInspectable var fillColor: UIColor = .brandSecondary {
        didSet {
            self.setup()
        }
    }
    @IBInspectable var textColor: UIColor = .white {
        didSet {
            self.setup()
        }
    }
    
    override func setup() {
        super.setup()
        setTitleColor(textColor, for: .normal)
        backgroundColor = fillColor
    }
}
