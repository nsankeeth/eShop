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
import Alamofire
import MapKit

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
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        locManager.requestWhenInUseAuthorization()
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        uploadImageButton.addTarget(self, action: #selector(didTapUploadImageButton), for: .touchUpInside)
        uploadImageButton.configure(color: backgroundColor,
                              font: uploadButtonFont,
                              cornerRadius: 10,
                              backgroundColor: tintColor)
        uploadImageButton.setTitle("Upload Image", for: .normal)
        
        postItemButton.addTarget(self, action: #selector(didTapPostItemButton), for: .touchUpInside)
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
    
    @objc func didTapPostItemButton() {
        guard let image = imageView.image, !(image == UIImage(named: "placeholder")) else {
            validate(with: "Image")
            return
        }
        guard let title = titleTextField.text, !title.isEmpty else {
            validate(with: "Title")
            return
        }
        guard let price = priceTextField.text, !price.isEmpty else {
            validate(with: "Price")
            return
        }
        guard let description = descriptionTextField.text, !description.isEmpty else {
            validate(with: "Description")
            return
        }
        let parameters: [String:String] = ["title": title, "description": description, "price": price]
        process(with: parameters)
    }
    
    func process(with parameters: [String:String]) {
        var parameters = parameters
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading"
        hud.show(in: self.view)
        let storageManager = FirebaseStorageManager()
        storageManager.upload(imageView.image!) { (success, url) in
            if (success) {
                hud.textLabel.text = "Posting"
                hud.show(in: self.view)
                let coordinates = self.getCoordinates()
                parameters["image_url"] = url.absoluteString
                parameters["latitude"] = coordinates["latitude"]
                parameters["longitude"] = coordinates["longitude"]
                print(parameters)
                self.post(with: parameters) { (success) in
                    if (success) {
                        hud.textLabel.text = "Successfully Posted!"
                        hud.indicatorView = JGProgressHUDSuccessIndicatorView.init()
                        hud.show(in: self.view)
                        hud.dismiss(afterDelay: 3.0)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.dismiss(animated: true, completion: nil)
                        }
                    } else {
                        hud.textLabel.text = "Posting Failed"
                        hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
                        hud.show(in: self.view)
                        hud.dismiss(afterDelay: 3.0)
                    }
                }
            } else {
                hud.textLabel.text = "Upload Failed"
                hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 3.0)
            }
        }
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
        imageView.contentMode = .scaleAspectFill
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
    
    func post(with parameters: [String:String], completionBlock: @escaping (_ success: Bool) -> Void) {
        Alamofire.request("http://ec2-3-15-177-123.us-east-2.compute.amazonaws.com:3000/items", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
            switch (response.result) {
            case .success:
                completionBlock(true)
                print(response)
                break
            case .failure:
                completionBlock(false)
            }
        }
    }
    
    func getCoordinates() -> [String:String] {
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            guard let currentLocation = locManager.location else {
                return [:]
            }
            return ["latitude": String(currentLocation.coordinate.latitude), "longitude": String(currentLocation.coordinate.longitude)]
        }
        return [:]
    }
    
    func validate(with message: String) {
        let title = message + " Required"
        let message = "Provide all required data and proceed"
        
        let popup = PopupDialog(title: title, message: message)
        
        let done = CancelButton(title: "Done") {
            print("You canceled the popup dialog.")
        }
        
        popup.addButtons([done])
        self.present(popup, animated: true, completion: nil)
    }
}
