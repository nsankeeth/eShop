//
//  ItemsViewControllerViewController.swift
//  eShop
//
//  Created by Sankeeth Naguleswaran on 9/10/19.
//  Copyright © 2019 SE. All rights reserved.
//

import UIKit
import AAFloatingButton
import Alamofire
import SwiftyJSON
import AlamofireImage
import JGProgressHUD

class ItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loginButton: UIButton!
    
    private let backgroundColor = UIColor(hexString: "#ff5a66")
    private let tintColor: UIColor = .white
    
    var itemsData: JSON?
    var item: Item?
    
    private let buttonFont = UIFont.boldSystemFont(ofSize: 10)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginButton.configure(color: backgroundColor,
                              font: buttonFont,
                              cornerRadius: 10,
                              backgroundColor: tintColor)
        
        userNameLabel.text = FirebaseAuthManager.getUserName()
        tableView.tableFooterView = UIView()
        
        let loginType = UserDefaults.standard.integer(forKey: "loginType")
        
        if (loginType == 1) {
            self.view.aa_addFloatingButton("+", backgroundColor, size: 55, bottomMargin: 20) {
                self.performSegue(withIdentifier: "toAddItemViewController", sender: self)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let data = itemsData {
            
            return data.count
            
        } else {
            
            return 0
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        
        if let data = itemsData {
            cell.textLabel?.text = data[indexPath.row]["title"].string
            
            cell.detailTextLabel?.text = data[indexPath.row]["description"].string
            
            cell.imageView?.clipsToBounds = true
            cell.imageView?.layer.masksToBounds = true
            cell.imageView?.layer.cornerRadius = 10
            cell.imageView?.bounds = CGRect(x: 0, y: 0, width: 35, height: 35)
            cell.imageView?.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
            
            cell.imageView?.af_setImage(withURL: URL(string: data[indexPath.row]["image_url"].string!.components(separatedBy: ",")[0])!, placeholderImage: UIImage(named: "placeholder"), filter: nil, progress: nil, imageTransition: UIImageView.ImageTransition.curlDown(0.5), completion: nil)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let data = itemsData {
            let currentItem = Item(itemTitle: data[indexPath.row]["title"].string!, itemImageURL: data[indexPath.row]["image_url"].string!, itemDescription: data[indexPath.row]["description"].string!, itemPrice: data[indexPath.row]["price"].string!, itemLatitude: data[indexPath.row]["latitude"].string!, itemLongitude: data[indexPath.row]["longitude"].string!)
            
            item = currentItem
        }
        
        performSegue(withIdentifier: "toDetailViewController", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailViewController" {
            let destinationNavigationController = segue.destination as! UINavigationController
            let detailViewController = destinationNavigationController.topViewController as! DetailViewController
            detailViewController.itemObject = item
        }
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        FirebaseAuthManager.logoutUser()
    }
    
    func getData() {
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Loading"
        hud.show(in: self.view)
        Alamofire.request("http://ec2-3-15-177-123.us-east-2.compute.amazonaws.com:3000/items").responseJSON { response in
            
            do {
                hud.dismiss()
                let json = try JSON(data: response.data!)
                self.itemsData = json["items"]
                self.tableView.reloadData()
            } catch {
                hud.textLabel.text = "Loading Failed"
                hud.indicatorView = JGProgressHUDErrorIndicatorView.init()
                hud.show(in: self.view)
                hud.dismiss(afterDelay: 3.0)
                print(error)
            }
        }
    }

}
