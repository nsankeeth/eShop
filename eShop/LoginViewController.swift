//
//  ViewController.swift
//  eShop
//
//  Created by SE on 9/7/19.
//  Copyright © 2019 SE. All rights reserved.
//

import UIKit
import JGProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet var footerView: UIView!
    @IBOutlet weak var loginFooterButton: UIButton!
    
    private let backgroundColor: UIColor = .white
    private let tintColor = UIColor(hexString: "#ff5a66")
    
    private let titleFont = UIFont.boldSystemFont(ofSize: 30)
    private let buttonFont = UIFont.boldSystemFont(ofSize: 20)
    
    private let textFieldFont = UIFont.systemFont(ofSize: 16)
    private let textFieldColor = UIColor(hexString: "#B0B3C6")
    private let textFieldBorderColor = UIColor(hexString: "#B0B3C6")
    
    private var currentState: Int = loginState.login.rawValue
    private var stateName: String? = nil
    private var footerStateName: String? = nil
    
    enum loginState: Int {
        case register = 0
        case login = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        loadControllerView()
        titleLabel.font = titleFont
        titleLabel.textColor = tintColor
        
        usernameTextField.configure(color: textFieldColor,
                                        font: textFieldFont,
                                        cornerRadius: 55/2,
                                        borderColor: textFieldBorderColor,
                                        backgroundColor: backgroundColor,
                                        borderWidth: 1.0)
        usernameTextField.placeholder = "E-mail"
        usernameTextField.textContentType = .emailAddress
        usernameTextField.clipsToBounds = true
        
        passwordTextField.configure(color: textFieldColor,
                                    font: textFieldFont,
                                    cornerRadius: 55/2,
                                    borderColor: textFieldBorderColor,
                                    backgroundColor: backgroundColor,
                                    borderWidth: 1.0)
        passwordTextField.placeholder = "Password"
        passwordTextField.isSecureTextEntry = true
        passwordTextField.textContentType = .emailAddress
        passwordTextField.clipsToBounds = true
        
        loginButton.addTarget(self, action: #selector(didTapLoginButton), for: .touchUpInside)
        loginButton.configure(color: backgroundColor,
                              font: buttonFont,
                              cornerRadius: 55/2,
                              backgroundColor: tintColor)
        
        footerView.backgroundColor = tintColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func didTapLoginButton() {
        let authManager = FirebaseAuthManager()
        if (currentState == loginState.login.rawValue) {
            let spinner = showSpinner(with: "Processing")
            if let email = usernameTextField.text, let password = passwordTextField.text {
                authManager.createUser(email: email, password: password) {[weak self] (success, error) in
                    guard let `self` = self else { return }
                    if (success) {
                        spinner.textLabel.text = "Successfully Registered!"
                        spinner.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                        spinner.show(in: self.view)
                        spinner.dismiss(afterDelay: 3.0)
                    } else {
                        spinner.textLabel.text = error!
                        spinner.indicatorView = JGProgressHUDErrorIndicatorView.init()
                        spinner.show(in: self.view)
                        spinner.dismiss(afterDelay: 3.0)
                    }
                }
            }
        } else {
            let spinner = showSpinner(with: "Authenticating")
            authManager.loginUser(email: usernameTextField.text!, password: passwordTextField.text!) {(success, error) in
                if (success) {
                    spinner.dismiss()
                    self.performSegue(withIdentifier: "toItemsViewController", sender: self)
                } else {
                    spinner.textLabel.text = error?.description
                    spinner.indicatorView = JGProgressHUDErrorIndicatorView.init()
                    spinner.show(in: self.view)
                    spinner.dismiss(afterDelay: 3.0)
                }
            }
        }
    }
    
    func showSpinner(with message: String) -> JGProgressHUD {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = message
        hud.show(in: self.view)
        
        return hud
    }
    
    func loadCurrentState() {
        if (currentState == loginState.login.rawValue) {
            stateName = "Log In"
            footerStateName = "Register"
            currentState = loginState.register.rawValue
        } else {
            stateName = "Register"
            footerStateName = "Log In"
            currentState = loginState.login.rawValue
        }
    }
    
    @IBAction func footerAction(_ sender: UIButton) {
        resetFields()
        loadControllerView()
    }
    
    func loadControllerView() {
        loadCurrentState()
        titleLabel.text = stateName
        loginButton.setTitle(stateName, for: .normal)
        loginFooterButton.setTitle(footerStateName, for: .normal)
    }
    
    func resetFields() {
        usernameTextField.text = ""
        passwordTextField.text = ""
    }
    
}

