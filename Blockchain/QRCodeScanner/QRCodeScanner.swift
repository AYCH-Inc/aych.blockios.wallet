//
//  GenericDeviceCapture.swift
//  Blockchain
//
//  Created by Jack Pooley on 13/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

enum QRScannerError: Error {
    case unknown
    case avCaptureError(AVCaptureDeviceError)
    case badMetadataObject
}

protocol QRCodeScannerDelegate: class {
    func scanComplete(with result: NewResult<String, QRScannerError>)
    func didStartScanning()
    func didStopScanning()
}

extension QRCodeScannerDelegate {
    func didStartScanning() {}
}

protocol QRCodeScannerProtocol: class {
    var videoPreviewLayer: CALayer { get }
    var delegate: QRCodeScannerDelegate? { get set }
    
    func startReadingQRCode()
    func stopReadingQRCode(complete: (() -> Void)?)
}

protocol CaptureInputProtocol {
    var current: AVCaptureInput? { get }
}

extension AVCaptureInput: CaptureInputProtocol {
    var current: AVCaptureInput? {
        return self
    }
}

protocol CaptureOutputProtocol: class {
    var current: AVCaptureOutput? { get }
}

extension AVCaptureOutput: CaptureOutputProtocol {
    var current: AVCaptureOutput? {
        return self
    }
}

protocol CaptureSessionProtocol {
    var current: AVCaptureSession? { get }
    
    func startRunning()
    func stopRunning()
    
    func add(input: CaptureInputProtocol)
    func add(output: CaptureOutputProtocol)
}

extension AVCaptureSession: CaptureSessionProtocol {
    var current: AVCaptureSession? {
        return self
    }
    
    func add(input: CaptureInputProtocol) {
        addInput(input.current!)
    }
    
    func add(output: CaptureOutputProtocol) {
        addOutput(output.current!)
    }
}

protocol CaptureMetadataOutputProtocol: CaptureOutputProtocol {
    var metadataObjectTypes: [AVMetadataObject.ObjectType]! { get set }
    
    func setMetadataObjectsDelegate(_ objectsDelegate: AVCaptureMetadataOutputObjectsDelegate?, queue objectsCallbackQueue: DispatchQueue?)
}

extension AVCaptureMetadataOutput: CaptureMetadataOutputProtocol {}

@objc final class QRCodeScanner: NSObject, QRCodeScannerProtocol, AVCaptureMetadataOutputObjectsDelegate {
    
    weak var delegate: QRCodeScannerDelegate?
    
    let videoPreviewLayer: CALayer
    
    private let captureSession: CaptureSessionProtocol
    private let captureMetadataOutputBuilder: () -> CaptureMetadataOutputProtocol
    private let sessionQueue: DispatchQueue
    
    required init?(deviceInput: CaptureInputProtocol? = QRCodeScanner.runDeviceInputChecks(alertViewPresenter: AlertViewPresenter.shared), captureSession: CaptureSessionProtocol = AVCaptureSession(), captureMetadataOutputBuilder: @escaping () -> CaptureMetadataOutputProtocol = { AVCaptureMetadataOutput() }, sessionQueue: DispatchQueue = DispatchQueue(label: "com.blockchain.Blockchain.qrCodeScanner.sessionQueue", qos: .background)) {
        guard let deviceInput = deviceInput else { return nil }
        
        self.captureSession = captureSession
        self.captureMetadataOutputBuilder = captureMetadataOutputBuilder
        self.sessionQueue = sessionQueue
        
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession.current!)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer = videoPreviewLayer
        
        super.init()
        
        self.sessionQueue.async { [weak self] in
            self?.configure(with: deviceInput)
        }
    }
    
    func startReadingQRCode() {
        sessionQueue.async { [weak self] in
            self?.captureSession.startRunning()

            DispatchQueue.main.async {
                self?.delegate?.didStartScanning()
            }
        }
    }
    
    func stopReadingQRCode(complete: (() -> Void)? = nil) {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()

            DispatchQueue.main.async {
                self?.delegate?.didStopScanning()
                complete?()
            }
        }
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !metadataObjects.isEmpty,
            let metadataObject = metadataObjects.first,
            metadataObject.type == .qr,
            let codeObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = codeObject.stringValue else {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.scanComplete(with: .failure(QRScannerError.badMetadataObject))
            }
            return
        }
        stopReadingQRCode() { [weak self] in
            self?.delegate?.scanComplete(with: .success(stringValue))
        }
    }
    
    /// Check if the device input is accessible for scanning QR codes
    static func runDeviceInputChecks(alertViewPresenter: AlertViewPresenter) -> AVCaptureDeviceInput? {
        switch QRCodeScanner.deviceInput() {
        case .success(let deviceInput):
            return deviceInput
        case .failure(let scanError):
            guard case .avCaptureError(let error) = scanError else {
                alertViewPresenter.standardError(message: scanError.localizedDescription)
                return nil
            }
            
            switch error.type {
            case .failedToRetrieveDevice, .inputError:
                alertViewPresenter.standardError(message: error.localizedDescription)
            case .notAuthorized:
                alertViewPresenter.showNeedsCameraPermissionAlert()
            default:
                alertViewPresenter.standardError(message: error.localizedDescription)
            }
            
            return nil
        }
    }
    
    private static func deviceInput() -> NewResult<AVCaptureDeviceInput, QRScannerError> {
        do {
            let input = try AVCaptureDeviceInput.deviceInputForQRScanner()
            return .success(input)
        } catch {
            guard let error = error as? AVCaptureDeviceError else {
                return .failure(.unknown)
            }
            return .failure(.avCaptureError(error))
        }
    }
    
    private func configure(with deviceInput: CaptureInputProtocol) {
        captureSession.add(input: deviceInput)
        
        let captureMetadataOutput = captureMetadataOutputBuilder()
        captureSession.add(output: captureMetadataOutput)
        
        let captureQueue = DispatchQueue(label: "com.blockchain.Blockchain.qrCodeScanner.captureQueue")
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: captureQueue)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
    }
}
