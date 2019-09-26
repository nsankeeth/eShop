//
//  DetailViewController.swift
//  eShop
//
//  Created by Sankeeth Naguleswaran on 9/13/19.
//  Copyright © 2019 SE. All rights reserved.
//

import UIKit
import ImageSlideshow

class DetailViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet var slideshow: ImageSlideshow!
    
    private let backgroundColor = UIColor(hexString: "#ff5a66")
    var imageSource = [AlamofireSource]()
    
    var itemObject: Item?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.descriptionTextView.scrollRangeToVisible(NSRange(location: 0, length: 0))
        }
    }
    
    func loadData() {
        if let item = itemObject {
            titleLabel.text = item.title
            priceLabel.text = "Rs. " + item.price
            descriptionTextView.text = item.description
            
            initSlideshow(images: item.imageURL.components(separatedBy: ","))
        }
        
    }
    
    func initSlideshow(images urls: [String]) {
        for url in urls {
            imageSource.append(AlamofireSource(urlString: url)!)
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
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func findLocationButtonPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "toMapViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapViewController" {
            let mapViewController = segue.destination as! MapViewController
            if let item = itemObject {
                if let latitude = Double(item.latitude) {
                    mapViewController.latitude = latitude
                }
                
                if let longitude = Double(item.longitude) {
                    mapViewController.longitude = longitude
                }
                
            }
            
        }
        
    }
    
}

extension DetailViewController: ImageSlideshowDelegate {
    func imageSlideshow(_ imageSlideshow: ImageSlideshow, didChangeCurrentPageTo page: Int) {
        print("current page:", page)
    }
}
