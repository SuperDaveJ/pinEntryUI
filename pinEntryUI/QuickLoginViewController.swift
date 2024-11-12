//
//  ViewController.swift
//  pinEntryUI
//
//  Created by Dave Johnson on 1/10/18.
//  Copyright © 2018 Paycom. All rights reserved.
//

import UIKit

class QuickLoginViewController: UIViewController {
    
    var pinView: PinEntryView!
    var quickLoginMethod: QuickLoginMethod!
    var quickLoginScreenType: QuickLoginScreenType!
    var userName: String!
    var correctPIN: String!
    var primaryPIN: String!
    var confirmationPIN : String!
    var numberOfPINAttempts : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO: Stub Data
                quickLoginMethod = .touch
                quickLoginScreenType = .setup
                userName = "Joseph"
                correctPIN = "8888"
        
        let loginModel = LoginViewModel.setupLoginPage(quickLoginMethod: quickLoginMethod, quickLoginType: quickLoginScreenType, username: userName)
        pinView = PinEntryView(loginModel: loginModel)
        pinView.delegate = self
        
        pinView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(pinView)
        
        NSLayoutConstraint.activate([
            pinView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            pinView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            pinView.topAnchor.constraint(equalTo: self.view.topAnchor),
            pinView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

extension QuickLoginViewController: PinEntryViewDelegate {
    
    func pinEntryViewSetUpLaterButtonWasTapped(_ sender: PinEntryView) {
        
        // TODO: Handle Set Up Later here. Just proceed with login
    }
    
    func pinEntryViewOtherUserButtonWasTapped(_ sender: PinEntryView) {
        
        // TODO: Handle View Other User click here...
    }
    
    func pinEntryViewResetQuickLinkButtonWasTapped(_ sender: PinEntryView) {
        
        // TODO: Handle Reset QuickLink Settings here...
    }
    
    func pinEntryViewBiometricButtonWasTapped(_ sender: PinEntryView) {
        
        if quickLoginScreenType == .login {
            
            // TODO: Handle Biometric login here....
        } else {
            
            // TODO: Handle Biometric setup here...
        }
    }
    
    
    
    func pinEntryView(_ sender: PinEntryView, didEnter pin: String) {
        let pinChain = Chain(service: "PaycomEssService", account: "Pin")
        
        if pinView.loginType == .login {
            
            do {
                self.correctPIN = try pinChain.loadData()
            } catch {
                fatalError("Error: \(error), \(error.localizedDescription)")
            }
            
            // Check PIN for login
            if pin != self.correctPIN {
                
                self.numberOfPINAttempts += 1
                sender.invalidPin()
                
                if self.numberOfPINAttempts > 4 {
                    
                    do {
                        try pinChain.deleteItem()
                    } catch {
                        fatalError("Error: \(error), \(error.localizedDescription)")
                    }
                    
                    sender.updateInstructionLabel = "PIN Failed. Too Many Attempts"
                    sender.alternateOptions1Button.isHidden = true
                    sender.confirmationPinLabel.layer.position.y += 5
                    sender.confirmationPinLabel.animationFade(.up)
                    sender.pagePinTextField.resignFirstResponder()
                    
                    //TODO: PIN Failure. Return to setup
                }
            } else {
                sender.validPin()
                sender.updateInstructionLabel = "PIN Confirmed"
                sender.loginWelcomeBackLabel.fadeOut()
                sender.confirmationPinLabel.animationFade(.up)
                print("EURIKA is worked! PIN accepted and here we gooooooooo.....")
                
                // TODO: Handle Correct PIN Login here........
            }
            
        } else {
            
            // Handle PIN for Setup
            if primaryPIN == nil {
                
                primaryPIN = pin
                sender.updateInstructionLabel = "Confirm 4 digit PIN"
                sender.confirmationPinLabel.animationFade(.up)
            } else {
                
                confirmationPIN = pin
                
                if confirmationPIN == primaryPIN {
                    
                    // Pins Match ... Handle Authorization
                    sender.updateInstructionLabel = "PIN Confirmed"
                    sender.loginWelcomeBackLabel.fadeOut()
                    sender.alternateOptions1Button.isHidden = true
                    sender.confirmationPinLabel.layer.position.y += 5
                    sender.confirmationPinLabel.animationFade(.up)
                    sender.pagePinTextField.resignFirstResponder()
                    
                    // MARK: - Save Pin to Keychain
                    
                    do {
                        try pinChain.saveData(data: pin)
                    } catch {
                        fatalError("Error: \(error), \(error.localizedDescription)")
                    }
                    UserDefaults.standard.setValue(QuickLoginMethod.pin.rawValue, forKey: PaycomESSUserDefaultKeys.loginMethod)
                    
                } else {
                    
                    // Pins do not match ... Handle reset
                    primaryPIN = nil
                    confirmationPIN = nil
                    sender.invalidPin()
                    sender.updateInstructionLabel = "Choose PIN Again"
                    sender.confirmationPinLabel.layer.position.y += 5
                    sender.confirmationPinLabel.animationFade(.up)
                    let alert = UIAlertController(title: "Error", message: "PIN Does not match", preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
























