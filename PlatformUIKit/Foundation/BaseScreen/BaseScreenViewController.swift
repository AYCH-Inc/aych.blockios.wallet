//
//  BaseScreenViewController.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 19/06/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

open class BaseScreenViewController: UIViewController {
    
    // MARK: - Types
    
    private struct Constant {
        static let titleViewHeight: CGFloat = 40
    }
    
    // MARK: - Exposed
    
    /**
     The style of the navigation bar.
     Defines the background, and the content colors.
     */
    public var barStyle = Screen.Style.Bar.lightContent(ignoresStatusBar: false, background: .clear) {
        didSet {
            baseNavigationController?.navigationBar.titleTextAttributes = [
                .font: UIFont.mainMedium(16),
                .foregroundColor: barStyle.contentColor]
            setBackground(by: barStyle)
        }
    }
    
    /**
     The title style of the navigation bar.
     By setting this property, the title of the navigation bar
     readjusts its content.
     Also, if the title is `.none` - it becomes hidden
     */
    public var titleViewStyle = Screen.Style.TitleView.none {
        didSet {
            guard let navigationItem = currentNavigationItem else {
                return
            }
            switch titleViewStyle {
            case .text(value: let text):
                navigationItem.titleView = nil
                navigationItem.title = text
            case .image(name: let image, width: let width):
                let view = UIImageView(image: UIImage(named: image))
                view.contentMode = .scaleAspectFit
                view.layout(size: CGSize(width: width, height: Constant.titleViewHeight))
                navigationItem.titleView = view
                navigationItem.title = nil
            case .none:
                navigationItem.titleView = nil
                navigationItem.title = nil
            }
        }
    }
    
    /**
     The style of the left button in the navigation bar.
     By setting this property, the left button of the navigation bar
     readjusts its color and content (image / title).
     Also, if *leftButtonStyle* is *.none*, The left button becomes hidden
     */
    public var leadingButtonStyle = Screen.Style.LeadingButton.none {
        didSet {
            let itemType: NavigationBarButtonItem.ItemType
            if let content = leadingButtonStyle.content {
                itemType = NavigationBarButtonItem.ItemType.content(content: content) { [weak self] in
                    self?.navigationBarLeadingButtonPressed()
                }
            } else {
                itemType = .none
            }
            leadingBarButtonItem = NavigationBarButtonItem(type: itemType, color: barStyle.contentColor)
        }
    }
    
    /**
     The style of the right button in the navigation bar.
     By setting this property, the right button of the navigation bar
     readjusts its color and content (image / title).
     Also, if *rightButtonStyle* is *.none*, The right button becomes hidden,
     in that case, it won't be an accessibility element.
     */
    public var trailingButtonStyle = Screen.Style.TrailingButton.none {
        didSet {
            let itemType: NavigationBarButtonItem.ItemType
            switch trailingButtonStyle {
            case .content(let content):
                itemType = .content(content: content) { [weak self] in
                    self?.navigationBarTrailingButtonPressed()
                }
            case .processing:
                itemType = .processing
            case .qrCode:
                itemType = .content(content: trailingButtonStyle.content!) { [weak self] in
                    self?.navigationBarTrailingButtonPressed()
                }
            case .none:
                itemType = .none
            }
            rightBarButtonItem = NavigationBarButtonItem(type: itemType, color: barStyle.contentColor)
        }
    }
    
    // MARK: - Private
    
    /// The ancestor navigation controller
    private lazy var baseNavigationController: UINavigationController? = {
        var result: UIViewController? = self
        while result != nil && !(result is UINavigationController) {
            result = result?.parent
        }
        return result as? UINavigationController
    }()
    
    private lazy var currentViewController: UIViewController? = {
        return baseNavigationController?.topViewController
    }()
    
    private lazy var currentNavigationItem: UINavigationItem? = {
        return currentViewController?.navigationItem
    }()
    
    override open var preferredStatusBarStyle: UIStatusBarStyle {
        loadViewIfNeeded()
        return barStyle.statusBarStyle
    }
    
    private var rightBarButtonItem: UIBarButtonItem! {
        didSet {
            currentNavigationItem?.setRightBarButton(rightBarButtonItem, animated: false)
        }
    }
    
    private(set) var leadingBarButtonItem: UIBarButtonItem! {
        didSet {
            currentNavigationItem?.setLeftBarButton(leadingBarButtonItem, animated: false)
        }
    }
    
    // MARK: - Lifecycle
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        baseNavigationController?.navigationBar.isTranslucent = true
        setBackground(by: barStyle)
        if !barStyle.ignoresStatusBar {
            UIApplication.shared.statusBarStyle = barStyle.statusBarStyle
        }
        currentNavigationItem?.setHidesBackButton(true, animated: false)
    }
    
    // MARK: - Setup
    
    private func setBackground(by style: Screen.Style.Bar) {
        let animation = CATransition()
        animation.duration = 0.25
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.type = .fade
        baseNavigationController?.navigationBar.layer.add(animation, forKey: nil)
        baseNavigationController?.navigationBar.setBackgroundImage(
            .image(color: style.backgroundColor, size: view.bounds.size),
            for: .default
        )
        baseNavigationController?.navigationBar.shadowImage = UIImage()
    }
    
    // MARK: - Exposed
    
    public func set(barStyle: Screen.Style.Bar,
                    leadingButtonStyle: Screen.Style.LeadingButton = .none,
                    trailingButtonStyle: Screen.Style.TrailingButton = .none) {
        self.barStyle = barStyle
        self.leadingButtonStyle = leadingButtonStyle
        self.trailingButtonStyle = trailingButtonStyle
    }
    
    public func setNavigationBar(visible: Bool) {
        baseNavigationController?.navigationBar.isHidden = !visible
        baseNavigationController?.isNavigationBarHidden = !visible
    }
    
    // MARK: - User Interaction

    // TODO: Handle according to various styles
    open func navigationBarTrailingButtonPressed() {}
    
    open func navigationBarLeadingButtonPressed() {
        switch leadingButtonStyle {
        case .back:
            baseNavigationController?.popViewController(animated: true)
        case .close:
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}
