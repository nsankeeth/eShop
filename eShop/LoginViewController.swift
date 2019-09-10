//
//  ViewController.swift
//  eShop
//
//  Created by SE on 9/7/19.
//  Copyright © 2019 SE. All rights reserved.
//

import UIKit
import FirebaseAuth

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
            if let email = usernameTextField.text, let password = passwordTextField.text {
                authManager.createUser(email: email, password: password) {[weak self] (success, error) in
                    guard let `self` = self else { return }
                    var message: String = ""
                    if (success) {
                        message = "Successfully Registered!"
                    } else {
                        message = error!
                    }
                    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            authManager.loginUser(email: usernameTextField.text!, password: passwordTextField.text!) {(success, error) in
                if (success) {
                    print("Login Successful")
                } else {
                    print("Login Failure")
                }
            }
        }
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

