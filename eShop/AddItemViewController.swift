//
//  AddItemViewController.swift
//  eShop
//
//  Created by Sankeeth Naguleswaran on 9/13/19.
//  Copyright © 2019 SE. All rights reserved.
//

import UIKit
import JGProgressHUD
import PopupDialog

class AddItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    private let backgroundColor: UIColor = .white
    private let tintColor = UIColor(hexString: "#ff5a66")
    
    private let buttonFont = UIFont.boldSystemFont(ofSize: 10)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        uploadImageButton.addTarget(self, action: #selector(didTapUploadImageButton), for: .touchUpInside)
        uploadImageButton.configure(color: backgroundColor,
                              font: buttonFont,
                              cornerRadius: 10,
                              backgroundColor: tintColor)
        uploadImageButton.setTitle("Upload Image", for: .normal)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapUploadImageButton() {
        let title = "Image Source"
        let message = "Choose image source"
        
        let popup = PopupDialog(title: title, message: message)
        
        let camera = DefaultButton(title: "Camera", dismissOnTap: true) {
            self.presentImagePicker(for: .camera)
        }
        
        let photoLibrary = DefaultButton(title: "Photo Library", dismissOnTap: true) {
            self.presentImagePicker(for: .photoLibrary)
        }
        
        let cancel = CancelButton(title: "CANCEL") {
            print("You canceled the popup dialog.")
        }
        
        popup.addButtons([camera, photoLibrary, cancel])
        self.present(popup, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let userPickedImage = info[.editedImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        imageView.image = userPickedImage
        uploadImageButton.setTitle("Change Image", for: .normal)
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentImagePicker(for sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = sourceType
        present(imagePicker, animated: true, completion: nil)
    }

}
