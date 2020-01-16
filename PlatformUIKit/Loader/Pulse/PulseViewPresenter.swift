//
//  PulseViewPresenter.swift
//  PlatformUIKit
//
//  Created by AlexM on 8/26/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift
import ToolKit
import PlatformKit

/// Presenter in charge of displaying a `PulseAnimationView`.
/// Note that though this API is very similar to that of the Loader, this
/// `PulseAnimationView` isn't necessarily meant for loading, but rather an on-boarding
/// tutorial. It servers as a CTA when the user creats a wallet for the first time. 
@objc final public class PulseViewPresenter: NSObject, PulseViewPresenting {
    
    // MARK: - Types
    
    /// Describes the state of the `PulseAnimationView`
    enum State {
        case animating
        case hidden
        
        /// Returns `true` if the `PulseAnimationView` is currently animating
        var isAnimating: Bool {
            switch self {
            case .animating:
                return true
            case .hidden:
                return false
            }
        }
    }
    
    // MARK: - Properties
    
    /// The shared instance of the pulse view
    public static let shared = PulseViewPresenter()
    
    /// sharedInstance function declared so that the LoadingViewPresenter singleton can be accessed
    /// from Obj-C. Should deprecate this once all Obj-c references have been removed.
    @objc public class func sharedInstance() -> PulseViewPresenter { return shared }
    
    // Returns `.visible` if the `PulseAnimationView` is currently visible and animating
    public var visibility: Visibility {
        return state.isAnimating ? .visible : .hidden
    }
    
    /// Returns `true` if the `PulseAnimationView` is currently visible and animating
    @objc public var isVisible: Bool {
        return state.isAnimating
    }
    
    /// Controls the availability of the `PulseAnimationView` from outside.
    /// In case `isEnabled` is `false`, the loader does not show.
    /// `isEnabled` is thread-safe.
    @objc public var isEnabled: Bool {
        set {
            lock.lock()
            defer { lock.unlock() }
            self._isEnabled = newValue
        }
        get {
            lock.lock()
            defer { lock.unlock() }
            return _isEnabled
        }
    }
    
    private let bag: DisposeBag = DisposeBag()
    
    // Privately used by exposed `isEnabled` only.
    private var _isEnabled = true
    
    // The container of the `PulseAnimationView`. Allocated on demand, when done spinning it should be deallocated.
    private var view: PulseContainerViewProtocol!
    
    // Recursive lock for shared resources held by that class
    private let lock = NSRecursiveLock()
    
    /// The state of the `PulseAnimationView`
    private var state = State.hidden {
        didSet {
            switch (oldValue, state) {
            case (.hidden, .animating):
                view.animate()
            case (.animating, .hidden):
                view.fadeOut()
            case (.hidden, .hidden), (.animating, .animating):
                break
            }
        }
    }
    
    // MARK: - API
    
    /// Hides the `PulseAnimationView`
    public func hide() {
        Execution.MainQueue.dispatch { [weak self] in
            guard let self = self else { return }
            guard self.view != nil else { return }
            self.state = .hidden
            self.view = nil
        }
    }
    
    /// Shows the `PulseAnimationView` in a provided view
    public func show(viewModel: PulseViewModel) {
        guard viewModel.container.subviews.contains(where: { $0 is PulseContainerView }) == false else { return }
        Execution.MainQueue.dispatch { [weak self] in
            guard let self = self, self.isEnabled else { return }
            self.setupView(in: viewModel.container)
            self.view.selection.emit(onNext: { [weak self] _ in
                guard let self = self else { return }
                viewModel.onSelection()
                // We should hide the pulse when the user taps it.
                self.hide()
            })
            .disposed(by: self.bag)
            self.state = .animating
        }
    }
    
    // MARK: - Accessors
    
    private func setupView(in superview: UIView) {
        view = PulseContainerView()
        attach(to: superview)
    }
    
    /// Add the view to a superview
    private func attach(to superview: UIView) {
        superview.addSubview(view.viewRepresentation)
        view.viewRepresentation.layoutToSuperview(axis: .horizontal)
        view.viewRepresentation.layoutToSuperview(axis: .vertical)
        superview.layoutIfNeeded()
    }
}
