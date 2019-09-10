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
                print("Unable to register User - " )
                completionBlock(false, self.handleError(error!))
            }
        }
    }
    
    func handleError(_ error: Error) -> String? {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            return errorCode.errorMessage
        }
        return nil
    }
}
