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
import ImageSlideshow

class AddItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    @IBOutlet weak var uploadImageButton: UIButton!
    @IBOutlet weak var postItemButton: UIButton!
    @IBOutlet var footerView: UIView!
    @IBOutlet internal var titleTextField: UITextField!
    @IBOutlet internal var priceTextField: UITextField!
    @IBOutlet internal var descriptionTextField: UITextField!
    @IBOutlet var slideshow: ImageSlideshow!
    
    private let backgroundColor: UIColor = .white
    private let tintColor = UIColor(hexString: "#FE717B")
    
    private let uploadButtonFont = UIFont.boldSystemFont(ofSize: 10)
    private let postButtonFont = UIFont.boldSystemFont(ofSize: 15)
    
    private let textFieldFont = UIFont.systemFont(ofSize: 16)
    private let textFieldColor = UIColor.black
    private let textFieldBorderColor = UIColor(hexString: "#B0B3C6")
    
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    public var images = [UIImage]()
    public var imageSource = [ImageSource]()

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
        uploadImageButton.setTitle("Add Image(s)", for: .normal)
        
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
        
        initSlideshow()
    }
    
    func initSlideshow() {
        imageSource.removeAll()
        for image in images {
            imageSource.append(ImageSource.init(image: image))
        }
        slideshow.slideshowInterval = 5.0
        slideshow.pageIndicatorPosition = .init(horizontal: .center, vertical: .under)
        slideshow.contentScaleMode = UIView.ContentMode.scaleAspectFill
        
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = UIColor.lightGray
        pageControl.pageIndicatorTintColor = UIColor.black
        slideshow.pageIndicator = pageControl
        
        // optional way to show activity indicator during image load (skipping the line will show no activity indicator)
        slideshow.activityIndicator = DefaultActivityIndicator()
        slideshow.delegate = self
        
        // can be used with other sample sources as `afNetworkingSource`, `alamofireSource` or `sdWebImageSource` or `kingfisherSource`
        slideshow.setImageInputs((imageSource.count != 0) ? imageSource : [ImageSource.init(image: UIImage.init(named: "placeholder")!)] as [ImageSource])
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(AddItemViewController.didTap))
        slideshow.addGestureRecognizer(recognizer)
    }
    
    @objc func didTap() {
        if (imageSource.count == 0) {
            return
        }
        let fullScreenController = slideshow.presentFullScreenController(from: self)
        
        fullScreenController.slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
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
        if (imageSource.count == 0) {
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
        uploadImages(with: hud) { (success, urls) in
            if (success) {
                hud.textLabel.text = "Posting"
                hud.show(in: self.view)
                let coordinates = self.getCoordinates()
                parameters["image_url"] = urls
                parameters["latitude"] = coordinates["latitude"]
                parameters["longitude"] = coordinates["longitude"]
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
    
    func uploadImages(with progress: JGProgressHUD, completionBlock: @escaping (_ success: Bool, _ urls: String) -> Void) {
        var urls: String = ""
        let imageCount: Int = images.count
        var count: Int = 0
        for image in images {
            let storageManager = FirebaseStorageManager()
            storageManager.upload(image) { (success, url) in
                if (success) {
                    count += 1
                    urls.isEmpty ? (urls = url.absoluteString) : (urls += ",\(url.absoluteString)")
                    progress.textLabel.text = "Uploading"
                    progress.show(in: self.view)
                    if (count == imageCount) {
                        completionBlock(true, urls)
                    }
                } else {
                    count += 1
                    if (count == imageCount) {
                        completionBlock(false, urls)
                    }
                }
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
        
        images.append(userPickedImage)
        initSlideshow()
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

extension AddItemViewController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
