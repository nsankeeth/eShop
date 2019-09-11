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
    @IBOutlet weak var loginButton: UIButton!
    
    private let backgroundColor = UIColor(hexString: "#ff5a66")
    private let tintColor: UIColor = .white
    
    private let buttonFont = UIFont.boldSystemFont(ofSize: 10)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginButton.configure(color: backgroundColor,
                              font: buttonFont,
                              cornerRadius: 10,
                              backgroundColor: tintColor)
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
