//
//  FirebaseAuthManager.swift
//  eShop
//
//  Created by Sankeeth Naguleswaran on 9/9/19.
//  Copyright © 2019 SE. All rights reserved.
//

import FirebaseAuth
import UIKit

class FirebaseAuthManager {
    func createUser(email: String, password: String, completionBlock: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
            if let user = authResult?.user {
                print("Registered User - ", user)
                completionBlock(true, nil)
            } else {
                print("Unable to register user - ", error! )
                completionBlock(false, self.handleError(error!))
            }
        }
    }
    
    func loginUser(email: String, password: String, completionBlock: @escaping (_ success: Bool, _ errorMessage: String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error == nil {
                print("Logged User - ", user!)
                completionBlock(true, nil)
            } else{
                print("Unable to login user - ", error! )
                completionBlock(false, error?.localizedDescription)
            }
        }
    }
    
    func handleError(_ error: Error) -> String? {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            return errorCode.errorMessage
        }
        return nil
    }
    
    static func isLoggedIn() -> Bool {
        return (Auth.auth().currentUser != nil)
    }
    
    static func updateRootVC(){
        
        let status = isLoggedIn()
        var rootVC : UIViewController?
        
        if(status == true){
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemsvc") as! ItemsViewController
        }else{
            rootVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginvc") as! LoginViewController
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = rootVC
        
    }
    
    static func logoutUser() {
        try! Auth.auth().signOut()
        updateRootVC()
    }
    
    static func getUserName() -> String {
        if let username = Auth.auth().currentUser?.email {
            return username
        }
        return "None"
    }
}
