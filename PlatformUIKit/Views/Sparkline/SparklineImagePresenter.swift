//
//  SparklinePresenter.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/24/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit
import RxSwift
import RxRelay
import RxCocoa

public class SparklineImagePresenter {
    
    // MARK: - Public Properties
    
    public var state: Observable<State> {
        return stateRelay.asObservable()
    }
    
    public var image: Driver<UIImage?> {
        return imageRelay.asDriver()
    }
    
    // MARK: - Private Properties
    
    private let calculator: SparklineCalculator
    private let fillColor: UIColor
    private let scale: CGFloat
    private let imageRelay = BehaviorRelay<UIImage?>(value: nil)
    private let fillColorRelay = BehaviorRelay<UIColor>(value: .gray4)
    private let stateRelay = BehaviorRelay<State>(value: .empty)
    private let disposeBag = DisposeBag()
    
    // MARK: - Injected
    
    let interactor: SparklineInteracting
    let accessibility: Accessibility
    
    public init(with interactor: SparklineInteracting,
                calculator: SparklineCalculator,
                fillColor: UIColor,
                scale: CGFloat) {
        self.fillColor = fillColor
        self.scale = scale
        self.calculator = calculator
        self.interactor = interactor
        self.accessibility = Accessibility(id: .value(Accessibility.Identifier.SparklineView.prefix))
        
        self.interactor.calculationState.map(weak: self, { (self, calculationState) -> State in
            switch calculationState {
            case .calculating:
                return .loading
            case .invalid(let error):
                return .invalid
            case .value(let points):
                let path = self.calculator.sparkline(with: points)
                guard let image = self.imageFromPath(path) else { return .invalid }
                return .valid(image: image)
            }
        })
        .bind(to: stateRelay)
        .disposed(by: disposeBag)
        
        stateRelay.compactMap { [weak self] state -> UIImage? in
            guard let self = self else { return nil }
            guard case let .valid(image) = state else { return nil }
            return image
        }
        .bind(to: imageRelay)
        .disposed(by: disposeBag)
    }
    
    private func imageFromPath(_ path: UIBezierPath) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(calculator.size, false, scale)
        UIGraphicsBeginImageContext(calculator.size)
        fillColor.setStroke()
        path.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension SparklineImagePresenter {
    
    public enum State {
        /// There is no data to display
        case empty
        
        /// The data is being fetched
        case loading
        
        /// Valid state - data has been received
        case valid(image: UIImage)
        
        /// Invalid state - An error was thrown
        case invalid
        
        /// Returns the text value if there is a valid value
        public var value: UIImage? {
            switch self {
            case .valid(let value):
                return value
            default:
                return nil
            }
        }
    }
}
