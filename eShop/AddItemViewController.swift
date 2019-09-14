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
    @IBOutlet weak var postItemButton: UIButton!
    @IBOutlet var footerView: UIView!
    @IBOutlet internal var titleTextField: UITextField!
    @IBOutlet internal var priceTextField: UITextField!
    @IBOutlet internal var descriptionTextField: UITextField!
    
    private let backgroundColor: UIColor = .white
    private let tintColor = UIColor(hexString: "#FE717B")
    
    private let uploadButtonFont = UIFont.boldSystemFont(ofSize: 10)
    private let postButtonFont = UIFont.boldSystemFont(ofSize: 15)
    
    private let textFieldFont = UIFont.systemFont(ofSize: 16)
    private let textFieldColor = UIColor.black
    private let textFieldBorderColor = UIColor(hexString: "#B0B3C6")

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        uploadImageButton.addTarget(self, action: #selector(didTapUploadImageButton), for: .touchUpInside)
        uploadImageButton.configure(color: backgroundColor,
                              font: uploadButtonFont,
                              cornerRadius: 10,
                              backgroundColor: tintColor)
        uploadImageButton.setTitle("Upload Image", for: .normal)
        
        postItemButton.configure(color: tintColor,
                                 font: postButtonFont,
                                 cornerRadius: 10,
                                 backgroundColor: backgroundColor)
        postItemButton.setTitle("Post Item", for: .normal)
        footerView.backgroundColor = tintColor
        
        construct(titleTextField, with: "Item Title")
        construct(priceTextField, with: "Item Price")
        construct(descriptionTextField, with: "Item Description")
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.window?.endEditing(true)
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
    
    func construct(_ textField: UITextField, with name: String) {
        textField.configure(color: textFieldColor,
                                 font: textFieldFont,
                                 cornerRadius: 10,
                                 borderColor: textFieldBorderColor,
                                 backgroundColor: backgroundColor,
                                 borderWidth: 1.0)
        textField.placeholder = name
        textField.clipsToBounds = true
    }

}
