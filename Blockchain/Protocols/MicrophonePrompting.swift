//
//  MicrophonePrompting.swift
//  Blockchain
//
//  Created by AlexM on 8/2/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

protocol MicrophonePrompting: class {
    var permissionsRequestor: PermissionsRequestor { get set }
    var microphonePromptingDelegate: MicrophonePromptingDelegate? { get set }
    
    func checkMicrophonePermissions()
    func willUseMicrophone()
}

extension MicrophonePrompting {
    func checkMicrophonePermissions() {
        permissionsRequestor.requestPermissions([.microphone]) { [weak self] in
            guard let self = self else { return }
            self.microphonePromptingDelegate?.onMicrophonePromptingComplete()
        }
    }
    
    func willUseMicrophone() {
        if PermissionsRequestor.shouldDisplayMicrophonePermissionsRequest() {
            microphonePromptingDelegate?.promptToAcceptMicrophonePermissions(confirmHandler: {
                self.checkMicrophonePermissions()
            })
            return
        } else {
            microphonePromptingDelegate?.onMicrophonePromptingComplete()
        }
    }
}
