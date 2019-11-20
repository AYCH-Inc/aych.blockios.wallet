//
//  AssetSparklineView.swift
//  Blockchain
//
//  Created by AlexM on 10/25/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa

public final class AssetSparklineView: UIView {
    
    // MARK: - Injected
    
    public var presenter: AssetSparklinePresenter! {
        didSet {
            if presenter != nil {
                calculate()
            }
        }
    }
    
    // MARK: - Private Properties
    
    private var path: Driver<UIBezierPath?> {
        return pathRelay.asDriver()
    }
    
    private var lineColor: Driver<UIColor> {
        return Driver.just(presenter.lineColor)
    }
    
    private var fillColor: Driver<UIColor> {
        return Driver.just(.clear)
    }
    
    private var lineWidth: Driver<CGFloat> {
        return Driver.just(attributes.lineWidth)
    }
    
    private let pathRelay: BehaviorRelay<UIBezierPath?> = BehaviorRelay(value: nil)
    private let shape: CAShapeLayer = CAShapeLayer()
    private var disposeBag = DisposeBag()
    
    private lazy var attributes: SparklineAttributes = {
        return .init(size: .init(width: frame.width, height: frame.height))
    }()
    
    private lazy var calculator: SparklineCalculator = {
        let calculator = SparklineCalculator(attributes: attributes)
        return calculator
    }()
    
    // MARK: - Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func calculate() {
        let calculator = SparklineCalculator(attributes: .init(size: frame.size))
        presenter.state
            .compactMap { state -> UIBezierPath? in
                guard case let .valid(prices: prices) = state else { return nil }
                let path = calculator.sparkline(with: prices)
                return path
            }
            .bind(to: pathRelay)
            .disposed(by: disposeBag)
        
        lineWidth
            .drive(shape.rx.lineWidth)
            .disposed(by: disposeBag)
        
        lineColor
            .drive(shape.rx.strokeColor)
            .disposed(by: disposeBag)
        
        fillColor
            .drive(shape.rx.fillColor)
            .disposed(by: disposeBag)
    }
    
    private func setup() {
        if layer.sublayers == nil {
            shape.bounds = frame
            shape.position = center
            layer.addSublayer(shape)
        }
        
        path.drive(shape.rx.path)
            .disposed(by: disposeBag)
    }
}
