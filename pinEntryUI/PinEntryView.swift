//
//  PinEntryView.swift
//  pinEntryUI
//
//  Created by Dave Johnson on 1/10/18.
//  Copyright © 2018 Paycom. All rights reserved.
//

import UIKit

enum QuickLoginMethod: String {
    case face = "face"
    case touch = "touch"
    case pin = "pin"
}

enum QuickLoginScreenType {
    case login
    case setup
}

enum LastSwipe {
    case toPin
    case toBiometric
}

protocol PinEntryViewDelegate: class {
    func pinEntryView(_ sender: PinEntryView, didEnter pin: String)
    func pinEntryViewBiometricButtonWasTapped(_ sender: PinEntryView)
    func pinEntryViewSetUpLaterButtonWasTapped(_ sender: PinEntryView)
    func pinEntryViewOtherUserButtonWasTapped(_ sender: PinEntryView)
    func pinEntryViewResetQuickLinkButtonWasTapped(_ sender: PinEntryView)
}

class PinEntryView: UIView, UITextFieldDelegate {

    // MARK: - Set Initial Variables
    var containerBottomViewConstraint: NSLayoutConstraint!
    var logoHeightConstraint: NSLayoutConstraint!
    var logoWidthConstraint: NSLayoutConstraint!
    var logoTopConstraint: NSLayoutConstraint!
    var pinStackViewCenterConstraint: NSLayoutConstraint!
    var pinScreenIDIconCenterConstraint: NSLayoutConstraint!
    var confirmationPINLabelConstraint: NSLayoutConstraint!
    var loginType: QuickLoginScreenType = .login
    var loginModel = LoginModel()
    weak var delegate: PinEntryViewDelegate?
    var lastSwiped: LastSwipe = .toBiometric
    var updateInstructionLabel = ""{
        didSet {
            if updateInstructionLabel == "PIN Confirmed" {
                authenticationTypeInstructionsLabel.isHidden = true
                alternateOptions2Button.isHidden = true
                confirmationPinLabel.text = updateInstructionLabel
            } else {
                confirmationPinLabel.text = updateInstructionLabel
                //confirmationPinLabel.isHidden = !confirmationPinLabel.isHidden
                //animateConfirmItem()
            }
        }
    }
    
    // MARK: - Set Paycom Colors
    let paycomGreen = UIColor(red: 0, green: (131/255), blue: (63/255), alpha: 1.0)
    let lightGray = UIColor(red: (180/255), green: (180/255), blue: (180/255), alpha: 1.0)
    
    // MARK: - Set Up Page Views
    
    // Container View
    let containerView: UIView = {
        var containerView = UIView(frame: .zero)
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
    // Paycom Logo
    let pinScreenLogoView: UIImageView = {
        var pinScreenLogoView = UIImageView(frame: .zero)
        pinScreenLogoView.image = #imageLiteral(resourceName: "Paycom_Logo_White")
        return pinScreenLogoView
    }()
    
    // Login Page Welcome Back Text Label
    let loginWelcomeBackLabel: PaycomUILabel = {
        var loginWelcomeBackLabel = PaycomUILabel()
        loginWelcomeBackLabel.text = "Welcome Back"
        loginWelcomeBackLabel.textColor = .white
        return loginWelcomeBackLabel
    }()
    
    // Authentication Instructions
    let authenticationTypeInstructionsLabel: UILabel = {
        var authenticationTypeInstructionsLabel = UILabel(frame: .zero)
        authenticationTypeInstructionsLabel.text = "Touch the Face ID® Button To Authenticate"
        authenticationTypeInstructionsLabel.textColor = .white
        authenticationTypeInstructionsLabel.textAlignment = .center
        return authenticationTypeInstructionsLabel
    }()
    
    // Authentication ID Icon
    let pinScreenIDIconView: UIButton = {
        var pinScreenIDIconView = UIButton(frame: .zero)
        let image = UIImage(named: "faceID.png") as UIImage?
        pinScreenIDIconView.setImage(image, for: .normal)
        pinScreenIDIconView.addTarget(self, action: #selector(biometricAuthenticate), for: .touchUpInside)
        return pinScreenIDIconView
    }()
    
    // Confirmation Pin Label
    let confirmationPinLabel: PaycomUILabel = {
        var confirmationPinLabel = PaycomUILabel()
        confirmationPinLabel.text = "Confirm 4 digit PIN"
        confirmationPinLabel.textColor = .white
        confirmationPinLabel.layer.opacity = 0.0
        confirmationPinLabel.textAlignment = .center
        //confirmationPinLabel.isHidden = true
        return confirmationPinLabel
    }()
    
    // PIN Digit Views
    let pinDotsViewArray: [PinEntryDotView] = {
        var pinDotView: [PinEntryDotView] = []
        for i in 0..<4 {
            pinDotView.append(PinEntryDotView())
            pinDotView[i].widthAnchor.constraint(equalToConstant: 15).isActive = true
            pinDotView[i].heightAnchor.constraint(equalToConstant: 15).isActive = true
        }
        return pinDotView
    }()
    
    // PIN Stackview
    let pinStackView: UIStackView = {
        var stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.spacing = 25
        return stackView
    }()
    
    // Enter PIN Button
    let enterPinButton: UIButton = {
        var enterPinButton = UIButton(frame: .zero)
        enterPinButton.setTitle("Enter PIN", for: .normal)
        enterPinButton.setTitleColor(.white, for: .normal)
        enterPinButton.titleLabel?.font = UIFont(name: "Helvetica", size: 14)
        enterPinButton.isHidden = true
        enterPinButton.addTarget(self, action: #selector(pinButtonAction), for: .touchUpInside)
        return enterPinButton
    }()
    
    // Page Alternative Options 1
    let alternateOptions1Button: UIButton = {
        var alternateOptions1Button = UIButton(frame: .zero)
        alternateOptions1Button.setTitleColor(.white, for: .normal)
        return alternateOptions1Button
    }()
    
    // Page Alternative Options 2
    let alternateOptions2Button: UIButton = {
        var alternateOptions2Button = UIButton(frame: .zero)
        alternateOptions2Button.setTitleColor(.white, for: .normal)
        return alternateOptions2Button
    }()
    
    // Page PIN TextField
    let pagePinTextField: UITextField! = {
        var pagePinTextField = UITextField(frame: .zero)
        pagePinTextField.isHidden = true
        pagePinTextField.keyboardType = UIKeyboardType.numberPad
        return pagePinTextField
    }()
    
    // MARK: - Initialization Calls
    
    init(loginModel: LoginModel) {
        
        self.loginModel = loginModel
        pinScreenIDIconView.setImage(UIImage.init(named: loginModel.loginScreenIcon.rawValue), for: .normal)
        //pinScreenIDIconView.image = UIImage.init(named: loginModel.loginScreenIcon.rawValue)
        super.init(frame: .zero)
        backgroundColor = paycomGreen
        self.loginType = loginModel.loginType
        
        // Set Initial Text
        authenticationTypeInstructionsLabel.text = loginModel.loginScreenInstructionText
        
        //alternateOptions1Button.setTitle(loginModel.loginScreenOptionButton1, for: .normal)
     
        alternateOptions1Button.setTitle(loginModel.loginScreenOptionButton1, for: .normal)
        alternateOptions2Button.setTitle(loginModel.loginScreenOptionButton2, for: .normal)
        
        if !loginModel.hasBiometricCapabilities {
            pinScreenIDIconView.isHidden = true
            pinStackView.isHidden = false
            pinStackViewCenterConstraint = pinStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
            alternateOptions1Button.isHidden = true
            pagePinTextField.becomeFirstResponder()
            //addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeKeypad)))
        } else {
            pinStackViewCenterConstraint = pinStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: 300)
        }
        
        if self.loginType == .setup {
            loginWelcomeBackLabel.isHidden = true
            alternateOptions1Button.addTarget(self, action: #selector(switchToEntryMethod), for: .touchUpInside)
            alternateOptions2Button.addTarget(self, action: #selector(setUpLater), for: .touchUpInside)
            if loginModel.hasBiometricCapabilities {
                addSwipeGestures()
            }
        } else {
            loginWelcomeBackLabel.text = "Welcome Back \(loginModel.loginScreenUsername)"
            alternateOptions1Button.addTarget(self, action: #selector(loginOtherUser), for: .touchUpInside)
            alternateOptions2Button.addTarget(self, action: #selector(resetQuickLinkSettings), for: .touchUpInside)
        }
        
        pagePinTextField.delegate = self
        
        // Add Container View
        addSubview(containerView)
        
        // Add Subviews
        pinDotsViewArray.forEach{pinStackView.addArrangedSubview($0)}
        let views: [UIView] = [pinStackView, pinStackView, pinScreenLogoView, pinScreenIDIconView, confirmationPinLabel, authenticationTypeInstructionsLabel, alternateOptions1Button, alternateOptions2Button, loginWelcomeBackLabel, pagePinTextField, enterPinButton]
        views.forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        views.forEach { containerView.addSubview($0) }

        containerBottomViewConstraint = containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        logoHeightConstraint = pinScreenLogoView.heightAnchor.constraint(equalToConstant: 77)
        logoWidthConstraint = pinScreenLogoView.widthAnchor.constraint(equalToConstant: 300)
        logoTopConstraint = pinScreenLogoView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 75)
        pinScreenIDIconCenterConstraint = pinScreenIDIconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        confirmationPINLabelConstraint = confirmationPinLabel.centerYAnchor.constraint(equalTo: pinScreenIDIconView.centerYAnchor, constant: 55)
        
        NSLayoutConstraint.activate([
            
            // ContainerView Constraints
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: self.topAnchor),
            containerBottomViewConstraint,
            
            // Paycom Logo Constraints
            
            logoWidthConstraint,
            logoHeightConstraint,
            logoTopConstraint,
            pinScreenLogoView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            // Authentication Type Icon Constraints
            pinScreenIDIconCenterConstraint,
            pinScreenIDIconView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            // Confirm Pin Entry Label
            confirmationPinLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            confirmationPinLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            confirmationPINLabelConstraint,
            
            //Login Welcome Back Label Constraints
            loginWelcomeBackLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            loginWelcomeBackLabel.topAnchor.constraint(equalTo: pinScreenLogoView.bottomAnchor, constant: 25),
            
            // Authentication Type Instructions Label Constraints
            authenticationTypeInstructionsLabel.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0),
            authenticationTypeInstructionsLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            authenticationTypeInstructionsLabel.topAnchor.constraint(equalTo: loginWelcomeBackLabel.bottomAnchor, constant: 10),
            
            // Alternate Options 1 Button Constraints
            alternateOptions1Button.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            alternateOptions1Button.topAnchor.constraint(equalTo: pinScreenIDIconView.bottomAnchor, constant: 85),
            
            // Alternate Options 2 Button Constraints
            alternateOptions2Button.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            alternateOptions2Button.topAnchor.constraint(equalTo: alternateOptions1Button.bottomAnchor, constant: 25),
            
            //PIN Dots Stackview Constraints
            pinStackViewCenterConstraint,
            pinStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            //Enter PIN Button Constraints
            enterPinButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            enterPinButton.topAnchor.constraint(equalTo: pinStackView.bottomAnchor, constant: 15),
            
            //Page PIN TextField For Debug or Later Viewing
            pagePinTextField.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            pagePinTextField.bottomAnchor.constraint(equalTo: pinStackView.topAnchor, constant: -15)
            
            ])

        // Notify if Keyboard Raises
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Custom Methods
    
    // Swipe Gesture
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.left:
                if lastSwiped == .toBiometric {
                    switchToEntryMethod(sender: nil)
                    lastSwiped = .toPin
                }
               
            case UISwipeGestureRecognizerDirection.right:
                if lastSwiped == .toPin {
                    switchToEntryMethod(sender: nil)
                    lastSwiped = .toBiometric
                }
  
            default:
                break
            }
        }
    }
    
    // Animate Screen Elements for view with keyboard raised
    func shrinkToPinScreen(_ keyboardHeight:CGFloat, duration time: Double) {
        
            NSLayoutConstraint.deactivate([self.containerBottomViewConstraint, self.logoWidthConstraint, self.logoHeightConstraint, self.logoTopConstraint])
        
            self.containerBottomViewConstraint = self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -keyboardHeight)
            self.logoHeightConstraint = self.pinScreenLogoView.heightAnchor.constraint(equalToConstant: 55)
            self.logoWidthConstraint = self.pinScreenLogoView.widthAnchor.constraint(equalToConstant: 214)
            self.logoTopConstraint = self.pinScreenLogoView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 55)
        
            NSLayoutConstraint.activate([self.containerBottomViewConstraint, self.logoWidthConstraint, self.logoHeightConstraint, self.logoTopConstraint])
        
            UIView.animate(withDuration: time, animations: {
                self.layoutIfNeeded()
            })
    }
    
    // Animate Screen Elements for view with keyboard lowered
    func returnFullScreen() {
        
            NSLayoutConstraint.deactivate([self.containerBottomViewConstraint, self.logoWidthConstraint, self.logoHeightConstraint, self.logoTopConstraint])
            
            self.containerBottomViewConstraint = self.containerView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0)
            self.logoHeightConstraint = self.pinScreenLogoView.heightAnchor.constraint(equalToConstant: 77)
            self.logoWidthConstraint = self.pinScreenLogoView.widthAnchor.constraint(equalToConstant: 300)
            self.logoTopConstraint = self.pinScreenLogoView.topAnchor.constraint(equalTo: self.containerView.topAnchor, constant: 75)
            
            NSLayoutConstraint.activate([self.containerBottomViewConstraint, self.logoWidthConstraint, self.logoHeightConstraint, self.logoTopConstraint])
            
            UIView.animate(withDuration: 0.33, animations: {
                self.layoutIfNeeded()
            })
    }
    
    // Restrict and Check Text Entered
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        if updatedText.count == 4 {
            togglePinDotView(pinToToggle: pinDotsViewArray[updatedText.count-1])
            delegate?.pinEntryView(self, didEnter: updatedText)
            
            let when = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.pagePinTextField.text = ""
                self.pinDotsViewArray.forEach {
                    $0.isActive = false
                }
            }
            
            //return false
        } else if updatedText.count < 5 {
            if currentText.count > updatedText.count {
                togglePinDotView(pinToToggle: pinDotsViewArray[currentText.count-1])
            } else {
                togglePinDotView(pinToToggle: pinDotsViewArray[updatedText.count-1])
            }
        }
        return updatedText.count < 5
    }
    
    func invalidPin() {
        pinStackView.shake()
    }
    
    func validPin() {
        removeGesture()
        enterPinButton.isHidden = true
        //alternateOptions1Button.isHidden = true
        pagePinTextField.resignFirstResponder()
        let when = DispatchTime.now() + 0.33
        DispatchQueue.main.asyncAfter(deadline: when) {
            UIView.animate(withDuration: 0.5, animations: {
                self.pinStackView.alpha = 0.0
                self.alternateOptions1Button.alpha = 0.0
            })
            //self.pinStackView.isHidden = true
        }
    }
    
    // Gesture Recognizer Calls
    
    func addSwipeGestures() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.addGestureRecognizer(swipeLeft)
    }
    
    func removeGesture() {
        for recognizer in self.gestureRecognizers ?? [] {
            self.removeGestureRecognizer(recognizer)
        }
    }
   

    // Toggle PIN Dot on/off
    
    func togglePinDotView(pinToToggle: PinEntryDotView){
        pinToToggle.isActive = !pinToToggle.isActive
    }
    
    // Switch Method of Entry between PIN and Biometric
    
    @objc func switchToEntryMethod(sender: AnyObject?){
        
        NSLayoutConstraint.deactivate([self.pinStackViewCenterConstraint, self.pinScreenIDIconCenterConstraint])
        
        if lastSwiped == .toPin { // Go to Biometric Option
        
            removeGesture()
            addSwipeGestures()
            
            authenticationTypeInstructionsLabel.text = loginModel.loginScreenInstructionText
            alternateOptions1Button.setTitle(loginModel.loginScreenOptionButton1, for: .normal)
            
            pagePinTextField.resignFirstResponder()
            
            pinStackViewCenterConstraint = pinStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: self.frame.width)
            pinScreenIDIconCenterConstraint = pinScreenIDIconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
            
            lastSwiped = .toBiometric
            returnFullScreen()
            
        } else { // Go to Pin Option
            
            authenticationTypeInstructionsLabel.text = loginModel.loginScreenInstructionTextSwipe
            alternateOptions1Button.setTitle(loginModel.loginScreenOptionButton1Swipe, for: .normal)
            
            pagePinTextField.becomeFirstResponder()
            
            pinStackViewCenterConstraint = pinStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
            pinScreenIDIconCenterConstraint = pinScreenIDIconView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: -self.frame.width)
            
            lastSwiped = .toPin
            //addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeKeypad)))
        }
        
        enterPinButton.isHidden = true
        NSLayoutConstraint.activate([self.pinStackViewCenterConstraint, self.pinScreenIDIconCenterConstraint])
        UIView.animate(withDuration: 0.33, animations: {
            self.layoutIfNeeded()
        })
    }
    
    // Raise Numeric Keypad for PIN Entry
    @objc func pinButtonAction(sender: UIButton!) {
        enterPinButton.isHidden = true
        pagePinTextField.becomeFirstResponder()
    }
    
    // Lower Numeric Keypad
    @objc func removeKeypad() {
        enterPinButton.isHidden = false
        pagePinTextField.resignFirstResponder()
        returnFullScreen()
    }
    
    // Capture keyboard motion for animation purposes
    @objc func keyboardWillShow(_ notification: Notification) {
        let animationTime = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.33
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            shrinkToPinScreen(keyboardHeight, duration: animationTime)
        }
    }
    
    // Login As Other User
    @objc func loginOtherUser(sender: UIButton!){
        
        delegate?.pinEntryViewOtherUserButtonWasTapped(self)
    }
    
    // Reset QuickLink Settings
    @objc func resetQuickLinkSettings() {
        
        delegate?.pinEntryViewResetQuickLinkButtonWasTapped(self)
    }
    
    // Set Up QuickLink Later
    @objc func setUpLater() {
        
        delegate?.pinEntryViewSetUpLaterButtonWasTapped(self)
    }
    
    // Biometric Authenticate
    func biometricAuthenticate() {
        
        delegate?.pinEntryViewBiometricButtonWasTapped(self)
    }
    
}

