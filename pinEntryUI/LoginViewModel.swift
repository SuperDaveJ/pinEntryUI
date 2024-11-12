//
//  LoginViewModel.swift
//  pinEntryUI
//
//  Created by Dave Johnson on 1/17/18.
//  Copyright © 2018 Paycom. All rights reserved.
//

import Foundation

struct LoginViewModel {
    
    static func setupLoginPage(quickLoginMethod: QuickLoginMethod, quickLoginType: QuickLoginScreenType, username: String) -> LoginModel {
        
        var loginModel = LoginModel()
        loginModel.loginType = quickLoginType
        loginModel.loginScreenUsername = username
        
        switch quickLoginType {
        case .login:
            loginModel.loginScreenWelcomeText = "Welcome Back \(username)."
            loginModel.loginScreenOptionButton1 = "Other User Login"
            loginModel.loginScreenOptionButton2 = "Reset Quick Login"
            break
            
        case .setup:
            //loginWelcomeBackLabel.isHidden = true
            
            if quickLoginMethod == .face {
                loginModel.loginScreenOptionButton1Swipe = "Use Face ID® Instead"
            } else {
                loginModel.loginScreenOptionButton1Swipe = "Use Touch ID® Instead"
            }
            loginModel.loginScreenInstructionTextSwipe = "Please choose a 4 Digit PIN"
            loginModel.loginScreenOptionButton1 = "Use PIN Instead"
            loginModel.loginScreenOptionButton2 = "Set Up Later"
            break
            
        }
        
        // Set Page for login method (Face, Touch, PIN)
        
        switch quickLoginMethod {
        case .face:
            loginModel.hasBiometricCapabilities = true
            loginModel.loginScreenIcon = .Face
            //enterPinButton.isHidden = true
            if quickLoginType == .login {
                loginModel.loginScreenInstructionText = "Touch the Face ID® button to login"
            } else {
                loginModel.loginScreenInstructionText = "Touch the Face Icon"
            }
            
            break
            
        case .touch:
            loginModel.hasBiometricCapabilities = true
            loginModel.loginScreenIcon = .Touch
            //pinStackView.isHidden = true
            //enterPinButton.isHidden = true
            if quickLoginType == .login {
                loginModel.loginScreenInstructionText =  "Touch the fingerprint button to login"
            } else {
                loginModel.loginScreenInstructionText =  "Touch the fingerprint button"
            }
            
            break
            
        case .pin:
            //pinScreenIDIconView.isHidden = true
            //pinStackView.isHidden = false
            if quickLoginType == .login {
                loginModel.loginScreenInstructionText =  "Please enter your 4 Digit PIN to login"
            } else {
                loginModel.loginScreenInstructionText =  "Choose a 4 Digit PIN"
            }
            break
        }
        return loginModel
    }
}
