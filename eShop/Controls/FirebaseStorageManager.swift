//
//  FirebaseStorageManager.swift
//  eShop
//
//  Created by Sankeeth Naguleswaran on 9/14/19.
//  Copyright © 2019 SE. All rights reserved.
//

import Foundation
import FirebaseStorage

class FirebaseStorageManager {
    func upload(_ image: UIImage, completionBlock: @escaping (_ success: Bool, _ url: URL) -> Void) {
        let storageRef = Storage.storage().reference().child(getFileName())
        if let uploadData = image.pngData() {
            storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                if error != nil {
                    completionBlock(false, nil!)
                } else {
                    storageRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            completionBlock(false, nil!)
                        }
                        completionBlock(true, downloadURL)
                    }
                }
            }
        }
    }
    
    private func getFileName() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm_\(Int.random(in: 0 ..< 100000))"
        return formatter.string(from: now) + ".png"
    }
}
