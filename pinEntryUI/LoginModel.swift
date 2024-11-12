//
//  LoginModel.swift
//  pinEntryUI
//
//  Created by Dave Johnson on 1/15/18.
//  Copyright © 2018 Paycom. All rights reserved.
//

import Foundation

enum LoginScreenIcon: String {
    
    case Face = "faceID.png"
    case Touch = "touchID.png"
}

struct LoginModel {
    var loginScreenWelcomeText: String = ""
    var loginScreenUsername: String = ""
    var loginScreenInstructionText: String = ""
    var loginScreenInstructionTextSwipe: String = ""
    var loginScreenIcon: LoginScreenIcon = .Touch
    var loginScreenOptionButton1: String = ""
    var loginScreenOptionButton1Swipe: String = ""
    var loginScreenOptionButton2: String = ""
    var loginType: QuickLoginScreenType = .login
    var hasBiometricCapabilities: Bool = false
    
    init() { }
}


