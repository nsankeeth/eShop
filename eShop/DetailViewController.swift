//
//  DetailViewController.swift
//  eShop
//
//  Created by Sankeeth Naguleswaran on 9/13/19.
//  Copyright © 2019 SE. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private let backgroundColor = UIColor(hexString: "#ff5a66")
    
    var itemObject: Item?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        loadData()
    }
    
    func loadData() {
        if let item = itemObject {
            titleLabel.text = item.title
            priceLabel.text = "Rs. " + item.price
            descriptionLabel.text = item.description
            
            let url = URL(string: item.imageURL)
            imageView.af_setImage(withURL: url!, placeholderImage: UIImage(named: "placeholder"))
        }
        
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
