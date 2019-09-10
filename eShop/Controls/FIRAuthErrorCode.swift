//
//  FIRAuthErrorCode.swift
//  eShop
//
//  Created by Sankeeth Naguleswaran on 9/10/19.
//  Copyright © 2019 SE. All rights reserved.
//

import FirebaseAuth
import UIKit

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "The email is already in use with another account"
        case .userDisabled:
            return "Your account has been disabled. Please contact support."
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Please enter a valid email"
        case .networkError:
            return "Network error. Please try again."
        case .weakPassword:
            return "Your password is too weak"
        default:
            return "Unknown error occurred"
        }
    }
}
