//
//  ItemsViewControllerViewController.swift
//  eShop
//
//  Created by Sankeeth Naguleswaran on 9/10/19.
//  Copyright © 2019 SE. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel?.text = "Sankeeth"
        
        return cell
    }
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        print("Logout button pressed")
    }

}
